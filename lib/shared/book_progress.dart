// 기본 책 정보 + 진행도, 최근 읽은 시간 추가 (서재용)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/book_model.dart';
import '../model/user_book_model.dart';

class BookProgress extends StatelessWidget {
  final BookModel book;
  final UserBookModel readingBook;
  final VoidCallback? onTap;
  final bool isEditingMode;
  final bool isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;

  const BookProgress({
    Key? key,
    required this.book,
    required this.readingBook,
    this.onTap,
    this.isEditingMode = false,
    this.isSelected = false,
    this.onCheckboxChanged,
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
    final progress = ((readingBook.lastPosition ?? 0.0) * 100).round();
    final progressStr = '$progress%';

    String lastReadTimeStr = formatElapsedTime(readingBook.updatedAt);

    return GestureDetector(
      onTap: isEditingMode ? null : onTap,
      child: SizedBox(
        width: 100,
        height: 210,
        child: Stack(
          children: [
            Column(
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
                      image: NetworkImage(book.imagePath!),
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
            if (isEditingMode)
              Positioned(
                top: 0,
                right: 0,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onCheckboxChanged,
                ),
              ),
          ]
        ),
      ),
    );
  }
}

