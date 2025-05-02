
// '독서 중' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../shared/size_config.dart';

class ReadingBookScreen extends StatefulWidget {
  const ReadingBookScreen({super.key});

  @override
  State<ReadingBookScreen> createState() => _ReadingBookScreenState();
}

class _ReadingBookScreenState extends State<ReadingBookScreen> {

  final List<String> titleList = ['데미안', '종의 기원', '책 제목', '책 제목', '책 제목', '책 제목'];
  final List<String> authorList = ['헤르만 헤세', '정유정', '저자 명', '저자 명', '저자 명', '저자 명'];
  final List<String> percentList = ['51%', '7%', '23%', '75%', '90%', '42%'];
  final List<String> lastReadList = ['3시간 전', '16시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전'];

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth*0.05, vertical: 16),
        child: GridView.builder(
          itemCount: titleList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.5
          ),
          itemBuilder: (context, index) {
            String title = titleList[index];
            String author = authorList[index];
            String percent = percentList[index];
            String lastReadTime = lastReadList[index];
            return readingInfo(title, author, percent, lastReadTime);
          },
        )
    );
  }

  // 책 위젯
  Widget readingInfo(String title, String author, String percent, String lastReadTime) {
    return SizedBox(
      width: 110,
      height: 223,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 110, height: 150,
            decoration: BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(8)
            ),
          ),
          SizedBox(height: 4,),
          Text(title, style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16)
          ),
          Text(author, style: TextStyle(
              color: Color(0xff777777),
              fontWeight: FontWeight.w400,
              fontSize: 14)
          ),
          Row(
            children: [
              Row(
                children: [
                  Icon(Icons.library_add_check_outlined, color: Color(0xff777777), size: 12,),
                  SizedBox(width: 2,),
                  Text(percent, style: TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w400,
                      fontSize: 12),
                  )
                ],
              ),
              SizedBox(width: 4,),
              Text(lastReadTime, style: TextStyle(
                  color: Color(0xff777777),
                  fontWeight: FontWeight.w400,
                  fontSize: 12)
              )
            ],
          )
        ],
      ),
    );
  }
}