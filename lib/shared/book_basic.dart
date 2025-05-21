// 책 표지, 책 제목, 작가명만 있는 간단한 책 위젯

import 'package:flutter/cupertino.dart';
import 'package:wanbook/model/book_model.dart';

class BookBasic extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;

  const BookBasic({Key? key, required this.book, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 93,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.imagePath != null
                    ? Image.asset(
                  book.imagePath!,
                  fit: BoxFit.cover,
                )
                    : Container(color: Color(0xffD9D9D9)),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff000000))),
                  Text(book.author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff777777))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
