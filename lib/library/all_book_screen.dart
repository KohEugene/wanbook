
// '전체 도서' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/question/purpose_screen.dart'; 


import '../shared/size_config.dart';

class AllBookScreen extends StatefulWidget {
  const AllBookScreen({super.key});

  @override
  State<AllBookScreen> createState() => _AllBookScreenState();
}

class _AllBookScreenState extends State<AllBookScreen> {

  final List<String> titleList = ['데미안', '종의 기원', '소년이 온다', '책 제목', '책 제목', '책 제목', '책 제목', '책 제목', '책 제목'];
  final List<String> authorList = ['헤르만 헤세', '정유정', '한강', '저자 명', '저자 명', '저자 명', '저자 명', '저자 명', '저자 명'];
  final List<String> percentList = ['0%', '7%', '100%', '23%', '75%', '100%', '90%', '42%', '100%'];
  final List<String> lastReadList = ['3시간 전', '16시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전'];

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
    return GestureDetector(
      onTap: () {
        if (percent == '0%') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReadingPurposeScreen()),
          );
        }
      },
      child: SizedBox(
        width: 110,
        height: 223,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: title == '데미안' ? null : Color(0xffD9D9D9),
                image: title == '데미안'
                    ? DecorationImage(
                        image: AssetImage('assets/images/b_damian.png'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
            Text(author, style: const TextStyle(
                color: Color(0xff777777),
                fontWeight: FontWeight.w400,
                fontSize: 14)),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.library_add_check_outlined,
                        color: Color(0xff777777), size: 12),
                    const SizedBox(width: 2),
                    Text(percent, style: const TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w400,
                      fontSize: 12),
                    )
                  ],
                ),
                const SizedBox(width: 4),
                Text(lastReadTime, style: const TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 12))
              ],
            )
          ],
        ),
      ),
    );
  }
}