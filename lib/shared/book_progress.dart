// 기본 책 정보 + 진행도, 최근 읽은 시간 추가 (서재용)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/book_model.dart';
import '../model/user_book_model.dart';
import '../screen/ebook/book_screen.dart';
import '../screen/question/purpose_screen.dart';

class BookProgress extends StatelessWidget {
  final BookModel book;
  final UserBookModel readingBook;
  final VoidCallback? onTap;

  const BookProgress({
    Key? key,
    required this.book,
    required this.readingBook,
    this.onTap,
  }) : super(key: key);

  String formatElapsedTime(DateTime updatedAt) {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = book.totalPages ?? 1;

    final progress = ((readingBook.lastPosition / totalPages) * 100).clamp(0, 100).toInt();
    final progressStr = '$progress%';

    String lastReadTimeStr = formatElapsedTime(readingBook.updatedAt);

    return GestureDetector(
      onTap: () {
        final bookScreen = BookScreen(title: book.title);

        if (progress == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingPurposeScreen(title: book.title),
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
                color: book.imagePath == null ? Color(0xffD9D9D9) : null,
                image: book.imagePath != null
                    ? DecorationImage(
                  image: AssetImage(book.imagePath!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(book.title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(book.author,
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
                    Text(progressStr,
                        style: const TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        )
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Text(lastReadTimeStr,
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

