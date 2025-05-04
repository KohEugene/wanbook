// AI 도우미 시작 화면

import 'package:flutter/material.dart';
import 'package:wanbook/aichat/chat_screen.dart';

class ChatMainScreen extends StatelessWidget {
  final String title;

  const ChatMainScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: buildChatBody(),
    );
  }

  // 전체 본문
  Widget buildChatBody() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 72),
            buildChaekmeongImage(),
            SizedBox(height: 16),
            buildMainTitle(),
            SizedBox(height: 8),
            buildSubTitle(),
            SizedBox(height: 16),
            buildHintChips(),
            Spacer(),
            buildMessageInput(),
            SizedBox(height: 24),
          ],
        ),
      ),
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

  // 제목
  Widget buildMainTitle() {
    return Text(
      '도움이 필요하신가요?',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  // 밑에 줄글
  Widget buildSubTitle() {
    return Text(
      '아래는 많은 독서가들이 궁금해하는 것들이에요!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xff777777),
      ),
    );
  }

  // 질문 목록
  Widget buildHintChips() {
    final List<String> hints = ['데미안의 주제', '아브락사스의 의미', '오마주들'];

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: hints.map((hint) {
        return Chip(
          label: Text(hint),
          backgroundColor: Color(0xffE4E4E4),
          labelStyle: TextStyle(color: Color(0xff777777)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(2),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          side: BorderSide(color: Colors.transparent),
          shadowColor: Colors.transparent,
          elevation: 0,
        );
      }).toList(),
    );
  }

  // 메시지 입력창
  Widget buildMessageInput() {
    return TextField(
      cursorColor: Color(0xff0077FF),
      decoration: InputDecoration(
        hintText: '메시지를 입력하세요.',
        hintStyle: TextStyle(
            color: Color(0xff777777),
            fontWeight: FontWeight.w400,
            fontSize: 14
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xffE4E4E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xff0077FF), width: 2),
        )
      ),
    );
  }
}
