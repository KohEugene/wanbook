
// '전체 도서' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/question/purpose_screen.dart'; 
import 'package:wanbook/ebook/book_screen.dart';
import '../shared/size_config.dart';

class AllBookScreen extends StatefulWidget {
  const AllBookScreen({super.key});

  @override
  State<AllBookScreen> createState() => _AllBookScreenState();
}

class _AllBookScreenState extends State<AllBookScreen> {
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
      child: GridView.builder(
        itemCount: titleList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.5,
        ),
        itemBuilder: (context, index) {
          String title = titleList[index];
          String percent = percentList[index];
          String lastReadTime = lastReadList[index];
          return readingInfo(title, percent, lastReadTime);
        },
      ),
    );
  }

  // 책 위젯
  Widget readingInfo(String title, String percent, String lastReadTime) {
    final bookData = bookInfoMap[title];
    final author = bookData?['author'] ?? '작가 미상';
    final imagePath = bookData?['image'];

    return GestureDetector(
      onTap: () {
        final bookScreen = BookScreen(title: title);

        if (percent == '0%') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingPurposeScreen(title: title),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => bookScreen,
            ),
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
                color: imagePath == null ? Color(0xffD9D9D9) : null,
                image: imagePath != null
                    ? DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            Text(author,
                style: const TextStyle(
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
                    Text(percent,
                        style: const TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        )),
                  ],
                ),
                const SizedBox(width: 4),
                Text(lastReadTime,
                    style: const TextStyle(
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
