import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String message;
  final String title;

  const ChatScreen({super.key, required this.message, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'sender': 'user'|'bot', 'text': ...}

  @override
  void initState() {
    super.initState();
    // 초기 메시지 받아와서 사용자 봇 메시지로 구성
    _messages.add({'sender': 'user', 'text': widget.message});
    _messages.add({'sender': 'bot', 'text': '${widget.message}에 대한 답변입니다.'});
  }

  void _sendMessage(String input) {
    if (input.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': input.trim()});
      _messages.add({'sender': 'bot', 'text': '${input.trim()}에 대한 답변입니다.'});
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          onPressed: () {
            int count = 0;
            Navigator.popUntil(context, (route) => count++ == 2);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return msg['sender'] == 'user'
                    ? buildUserChat(msg['text']!)
                    : buildBotChat(msg['text']!);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: buildMessageInputArea(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 사용자 메시지
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
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  // 챗봇 응답 메시지
  Widget buildBotChat(String response) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/main_Chaekmeong_1.png',
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 12),
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
                child: Text(
                  response,
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 입력창 + 화살표 버튼
  Widget buildMessageInputArea() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: _sendMessage,
            cursorColor: const Color(0xff0077FF),
            decoration: InputDecoration(
              hintText: '메시지를 입력하세요.',
              hintStyle: const TextStyle(
                color: Color(0xff777777),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xffE4E4E4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xffE4E4E4)),
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
