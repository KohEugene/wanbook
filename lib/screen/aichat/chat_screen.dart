// AI 챗봇
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../../provider/user_provider.dart';
import '../../provider/chat_provider.dart';
import '../../model/chatmessage_model.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String message;
  final String title;
  final bool isFromHistory;

  const ChatScreen({super.key, required this.message, required this.title, this.isFromHistory = false,});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isBotTyping = false;
  bool _hasSentInitialQuestion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatHistory();
    });
  }

  void _loadChatHistory() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId ?? '';

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(widget.title)
        .collection('messages')
        .orderBy('timestamp')
        .get();

    setState(() {
      _messages.addAll(snapshot.docs.map((doc) => {
        'sender': doc['senderId'] == 'bot' ? 'bot' : 'user',
        'text': doc['text'] ?? '',
      }));
    });

    if (!_hasSentInitialQuestion && !widget.isFromHistory) {
      _hasSentInitialQuestion = true;
      _sendMessage(widget.message);
    }
  }

  void _sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final userMessage = ChatMessageModel(
      senderId: userId,
      text: input.trim(),
      timestamp: DateTime.now(),
      bookTitle: widget.title,
    );

    setState(() {
      _messages.add({'sender': 'user', 'text': input.trim()});
      _isBotTyping = true;
    });

    _controller.clear();

    await chatProvider.sendMessage(userId, widget.title, userMessage);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(widget.title)
        .set({
          'lastMessage': userMessage.text,
          'timestamp': userMessage.timestamp,
        }, SetOptions(merge: true));

    _getGPTResponse(input.trim());
  }

  Future<void> _getGPTResponse(String prompt) async {
    const apiKey = ''; 
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final systemForBook = """
    당신은 독서 도우미 AI입니다.
    지금 사용자가 대화하는 도서 제목은 "${widget.title}" 입니다.
    - 사용자가 메시지에 책 제목을 적지 않아도 기본적으로 "${widget.title}"을 기준으로 이해하고 답하세요.
    - 만약 사용자가 명확히 다른 책을 지칭하면 그 책으로 전환하되, 그렇지 않으면 계속 "${widget.title}" 기준으로 답하세요.
    - 가능한 한 책의 핵심 주제/인물/챕터 구조/핵심 문장/메시지/배경지식 중심으로 간결하게 대답하세요.
    """;

    final body = json.encode({
      "model": "gpt-3.5-turbo", 
      "messages": [
        {"role": "system", "content": systemForBook},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
    });

    try {
      final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['choices'][0]['message']['content'].trim();

        final userId = Provider.of<UserProvider>(context, listen: false).user?.userId ?? '';
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);

        final botMessage = ChatMessageModel(
          senderId: 'bot',
          text: reply,
          timestamp: DateTime.now(),
          bookTitle: widget.title,
        );

        setState(() {
          _isBotTyping = false;
          _messages.add({'sender': 'bot', 'text': reply});
        });

        await chatProvider.sendMessage(userId, widget.title, botMessage);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('chats')
            .doc(widget.title)
            .set({
              'lastMessage': botMessage.text,
              'timestamp': botMessage.timestamp,
            }, SetOptions(merge: true));
      } else {
        _showError("오류가 발생했어요. 다시 시도해 주세요.");
      }
    } catch (e) {
      _showError("인터넷 연결을 확인해 주세요.");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _isBotTyping = false;
      _messages.add({'sender': 'bot', 'text': message});
    });
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isBotTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isBotTyping && index == _messages.length) {
                    return buildBotChat("", isTyping: true);
                  }
                  final msg = _messages[index];
                  return msg['sender'] == 'user'
                      ? buildUserChat(msg['text']!)
                      : buildBotChat(msg['text']!);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: buildMessageInputArea(),
            ),
          ],
        ),
      );
    }

  Widget buildUserChat(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xff0077FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(2),
            ),
          ),
          child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }

  // 채팅
  Widget buildBotChat(String response, {bool isTyping = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/main_Chaekmeong_1.svg',
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: isTyping
                    ? const TypingDots()
                    : Text(response, style: const TextStyle(fontSize: 14, color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 답변 대기중
  Widget buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/main_Chaekmeong_1.svg',
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget buildMessageInputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: _sendMessage,
            cursorColor: const Color(0xff0077FF),
            decoration: InputDecoration(
              hintText: '책에 대해 궁금한 점을 물어보세요',
              hintStyle: const TextStyle(color: Color(0xff777777), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffE4E4E4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xff0077FF), width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _sendMessage(_controller.text),
          child: const CircleAvatar(
            backgroundColor: Color(0xff0077FF),
            child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ... 애니메이션
class TypingDots extends StatefulWidget {
  const TypingDots({Key? key}) : super(key: key);

  @override
  _TypingDotsState createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotCount = StepTween(begin: 1, end: 4).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (_, __) {   
        String dots = '.' * _dotCount.value;
        return Text(
          "답변 작성 중$dots",
          style: const TextStyle(fontSize: 14, color: Colors.black),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
