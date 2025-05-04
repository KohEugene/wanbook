
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
  final List<String> titleList = [
    '데미안', '종의 기원', '소년이 온다', '이기적 유전자', '싯다르타', '침묵의 봄', '이방인', '아몬드', '눈먼 자들의 도시'
  ];

  final List<String> percentList = [
    '0%', '7%', '100%', '23%', '75%', '100%', '0%', '42%', '100%'
  ];

  final List<String> lastReadList = [
    '3시간 전', '16시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전'
  ];

  final Map<String, Map<String, String>> bookInfoMap = {
    '데미안': {
      'author': '헤르만 헤세',
      'image': 'assets/images/b_damian.png',
    },
    '소년이 온다': {
      'author': '한강',
      'image': 'assets/images/b_boycome.png',
    },
    '종의 기원': {
      'author': '정유정',
      'image': 'assets/images/b_jong.png',
    },
    '이기적 유전자': {
      'author': '리처드 도킨스',
      'image': 'assets/images/b_gene.png',
    },
    '싯다르타': {
      'author': '헤르만 헤세',
      'image': 'assets/images/b_shitda.png',
    },
    '침묵의 봄': {
      'author': '레이첼 카슨',
      'image': 'assets/images/b_spring.png',
    },
    '이방인': {
      'author': '알베르 카뮈',
      'image': 'assets/images/b_gentile.png',
    },
    '아몬드': {
      'author': '손원평',
      'image': 'assets/images/b_amond.png',
    },
    '눈먼 자들의 도시': {
      'author': '사라마구',
      'image': 'assets/images/b_eye.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    // '100%'가 아닌 책
    List<int> readingIndexes = [];
    for (int i = 0; i < percentList.length; i++) {
      if (percentList[i] != '100%') {
        readingIndexes.add(i);
      }
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
        child: GridView.builder(
          itemCount: readingIndexes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            int originalIndex = readingIndexes[index];
            String title = titleList[originalIndex];
            String author = bookInfoMap[title]!['author']!;
            String imagePath = bookInfoMap[title]!['image']!;
            String percent = percentList[originalIndex];
            String lastReadTime = lastReadList[originalIndex];
            return readingInfo(title, author, imagePath, percent, lastReadTime);
          },
        ),
      ),
    );
  }

  // 책 위젯
  Widget readingInfo(String title, String author, String imagePath, String percent, String lastReadTime) {
    return SizedBox(
      width: 100,
      height: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Color(0xffD9D9D9),
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(author, style: TextStyle(
              color: Color(0xff777777),
              fontWeight: FontWeight.w400,
              fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Row(
            children: [
              Icon(Icons.library_add_check_outlined, color: Color(0xff777777), size: 12),
              SizedBox(width: 2),
              Text(percent, style: TextStyle(
                  color: Color(0xff777777),
                  fontWeight: FontWeight.w400,
                  fontSize: 11)),
              SizedBox(width: 4),
              Text(lastReadTime, style: TextStyle(
                  color: Color(0xff777777),
                  fontWeight: FontWeight.w400,
                  fontSize: 11))
            ],
          )
        ],
      ),
    );
  }
}