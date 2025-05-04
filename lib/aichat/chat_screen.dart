import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String message;
  final String title;

  const ChatScreen({super.key, required this.message, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
      body: buildChatBody(),
    );
  }

  // 전체 챗 화면
  Widget buildChatBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          buildUserChat(widget.message),
          const SizedBox(height: 16),
          buildBotChat("주제에 대한 답변주제에 대한 답변주제에 대한 답변주제에 대한 답변주제에 대한 답변주제에 대한 답변주제에 대한 답변"),
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
          maxWidth: MediaQuery.of(context).size.width * 0.65, // 화면 너비의 65%까지만 말풍선
        ),
        child: Container(
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
            style: const TextStyle(color: Colors.white, fontSize: 14),
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
                maxWidth: MediaQuery.of(context).size.width * 0.7, // 화면 너비의 7%까지만 말풍선
              ),
              child: Container(
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
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}