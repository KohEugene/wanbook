
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
    '데미안', '오만과 편견', '소년이 온다', '변신', '노인과 바다', '인간실격', '이방인', '아몬드', '눈먼 자들의 도시'
  ];

  final List<String> percentList = [
    '0%', '7%', '100%', '23%', '75%', '100%', '0%', '42%', '100%'
  ];

  final List<String> lastReadList = [
    '3시간 전', '16시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전'
  ];

  final Map<String, Map<String, String>> bookInfoMap = {
    '데미안': {'author': '헤르만 헤세', 'image': 'assets/images/b_damian.png'},
    '소년이 온다': {'author': '한강', 'image': 'assets/images/b_boycome.png'},
    '오만과 편견': {'author': '제인 오스틴', 'image': 'assets/images/b_op.png'},
    '변신': {'author': '프란츠 카프카', 'image': 'assets/images/b_change.png'},
    '인간실격': {'author': '다자이 오사무', 'image': 'assets/images/b_human.png'},
    '노인과 바다': {'author': '어니스트 헤밍웨이', 'image': 'assets/images/b_sea.png'},
    '이방인': {'author': '알베르 카뮈', 'image': 'assets/images/b_gentile.png'},
    '아몬드': {'author': '손원평', 'image': 'assets/images/b_amond.png'},
    '눈먼 자들의 도시': {'author': '사라마구', 'image': 'assets/images/b_eye.png'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
        child: GridView.builder(
          itemCount: titleList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            String title = titleList[index];
            String percent = percentList[index];
            String lastReadTime = lastReadList[index];
            return readingInfo(title, percent, lastReadTime);
          },
        ),
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
        width: 100,
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 140,
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
                    fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
            ),
            Text(author,
                style: const TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
            ),
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
                          fontSize: 11,
                        )
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Text(lastReadTime,
                    style: const TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 11)
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
