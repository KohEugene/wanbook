
// '전체 도서' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/shared/book_progress.dart';
import '../../model/book_model.dart';
import '../../shared/size_config.dart';

class AllBookScreen extends StatefulWidget {
  const AllBookScreen({super.key});

  @override
  State<AllBookScreen> createState() => _AllBookScreenState();
}

class _AllBookScreenState extends State<AllBookScreen> {
  List<BookModel> books = [
    BookModel(title: '데미안', author: '헤르만 헤세', imagePath: 'assets/images/b_damian.png', percent: '0%', lastReadTime: '3시간 전'),
    BookModel(title: '오만과 편견', author: '제인 오스틴', imagePath: 'assets/images/b_op.png', percent: '7%', lastReadTime: '16시간 전'),
    BookModel(title: '소년이 온다', author: '한강', imagePath: 'assets/images/b_boycome.png', percent: '100%', lastReadTime: '24시간 전'),
    BookModel(title: '변신', author: '프란츠 카프카', imagePath: 'assets/images/b_change.png', percent: '23%', lastReadTime: '17시간 전'),
    BookModel(title: '노인과 바다', author: '어니스트 헤밍웨이', imagePath: 'assets/images/b_sea.png', percent: '75%', lastReadTime: '9시간 전'),
    BookModel(title: '인간실격', author: '다자이 오사무', imagePath: 'assets/images/b_human.png', percent: '100%', lastReadTime: '3일 전'),
    BookModel(title: '이방인', author: '알베르 카뮈', imagePath: 'assets/images/b_gentile.png', percent: '0%', lastReadTime: '1시간 전'),
    BookModel(title: '아몬드', author: '손원평', imagePath: 'assets/images/b_amond.png', percent: '42%', lastReadTime: '7시간 전'),
    BookModel(title: '눈먼 자들의 도시', author: '사라마구', imagePath: 'assets/images/b_eye.png', percent: '100%', lastReadTime: '2일 전'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
        child: GridView.builder(
          itemCount: books.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            return BookProgress(book: books[index]);
          },
        ),
      ),
    );
  }
}
