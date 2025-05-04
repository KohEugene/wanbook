import 'package:flutter/material.dart';
import 'package:wanbook/aichat/chat_screen.dart';

class ChatMainScreen extends StatefulWidget {
  final String title;

  const ChatMainScreen({super.key, required this.title});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  void navigateToChatScreen(String message) {
    if (message.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          message: message.trim(),
          title: widget.title,
        ),
      ),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 72),
                  buildChaekmeongImage(),
                  const SizedBox(height: 16),
                  buildMainTitle(),
                  const SizedBox(height: 8),
                  buildSubTitle(),
                  const SizedBox(height: 16),
                  buildHintChips(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: buildMessageInputArea(),
          ),
        ],
      ),
    );
  }

  // 힌트 목록
  Widget buildHintChips() {
    final List<String> hints = ['데미안의 주제', '아브락사스의 의미', '오마주들'];

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: hints.map((hint) {
        return GestureDetector(
          onTap: () => navigateToChatScreen(hint),
          child: Chip(
            label: Text(hint),
            backgroundColor: const Color(0xffE4E4E4),
            labelStyle: const TextStyle(color: Color(0xff777777)),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }

  // 책멍이 이미지
  Widget buildChaekmeongImage() {
    return Image.asset(
      'assets/images/main_Chaekmeong_1.png',
      width: 200,
      height: 200,
    );
  }

  // 문구
  Widget buildMainTitle() {
    return const Text(
      '도움이 필요하신가요?',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  // 글씨
  Widget buildSubTitle() {
    return const Text(
      '아래는 많은 독서가들이 궁금해하는 것들이에요!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xff777777),
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
            cursorColor: const Color(0xff0077FF),
            decoration: InputDecoration(
              hintText: '메시지를 입력하세요.',
              hintStyle: const TextStyle(
                color: Color(0xff777777),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
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
            onSubmitted: navigateToChatScreen,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => navigateToChatScreen(_controller.text),
          child: const CircleAvatar(
            backgroundColor: Color(0xff0077FF),
            child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
