
// 챗봇 목록

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/shared/menu_bottom.dart';

class ChatlistScreen extends StatefulWidget {
  const ChatlistScreen({super.key});

  @override
  State<ChatlistScreen> createState() => _ChatlistScreenState();
}

class _ChatlistScreenState extends State<ChatlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('채팅 목록'),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        },
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
    );
  }
}
