
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16,),
                  chatRecord('데미안', '데미안의 주제 좀 알려줘', '오후 11:40'),
                  chatRecord('책 제목', '(제일 최근 물어본 질문)', '오전 9:30')
                ],
              ),
            )
          )
      ),
    );
  }

  Widget chatRecord(String title, String chat, String time) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(15)
            ),
          ),
          SizedBox(width: 16,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5,),
              Text(title,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,  // 책 제목이 긴 경우 말줄임표 이용해 한 줄만 출력
              ),
              SizedBox(height: 5,),
              Text(chat, style: TextStyle(
                color: Color(0xffADADAD),
                fontWeight: FontWeight.w400,
                fontSize: 12),
              )
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
