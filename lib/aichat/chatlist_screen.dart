
// 챗봇 목록

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../shared/size_config.dart';

class ChatlistScreen extends StatefulWidget {
  const ChatlistScreen({super.key});

  @override
  State<ChatlistScreen> createState() => _ChatlistScreenState();
}

class _ChatlistScreenState extends State<ChatlistScreen> {

  final List<String> coverList = [
    'assets/images/b_damian.png', 'assets/images/b_gene.png', 'assets/images/b_gentile.png'
  ];

  final List<String> titleList = [
    '데미안', '이기적 유전자', '이방인'
  ];

  final List<String> lastMessageList = [
    '데미안의 주제 좀 알려줘', '이기적 유전자를 설명해줘', '이방인을 해석해줘'
  ];

  final List<String> lastChatList = [
    '오후 11:40', '오전 9:30', '오후 1:15'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅 목록'),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        },
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth*0.05,
            ),
            child: ListView.builder(
                itemCount: titleList.length,
                itemBuilder: (context, index) {
                  String imagePath = coverList[index];
                  String title = titleList[index];
                  String chat = lastMessageList[index];
                  String time = lastChatList[index];
                  return chatRecord(imagePath, title, chat, time);
                },
            )
          ),
      )
    );
  }

  // 책 당 채팅 목록
  Widget chatRecord(String imagePath, String title, String chat, String time) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                )
            ),
          ),
          SizedBox(width: 16,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,  // 책 제목이 긴 경우 말줄임표 이용해 한 줄만 출력
              ),
              SizedBox(height: 5,),
              Text(chat, style: TextStyle(
                  color: Color(0xffADADAD),
                  fontWeight: FontWeight.w400,
                  fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          Spacer(),
          Text(time, style: TextStyle(
              color: Color(0xffADADAD),
              fontWeight: FontWeight.w400,
              fontSize: 10),
          )
        ],
      ),
    );
  }
}
