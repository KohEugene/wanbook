
// '완독 도서' 탭 화면

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/shared/book_progress.dart';

import '../../model/book_model.dart';
import '../../model/user_book_model.dart';
import '../../provider/user_book_provider.dart';
import '../../provider/user_provider.dart';
import '../../shared/size_config.dart';
import '../ebook/book_screen.dart';

class FinishBookScreen extends StatefulWidget {
  final bool isEditingMode;
  final List<String> selectedBookIds;
  final void Function(String bookId, bool isChecked) onCheckboxChanged;

  const FinishBookScreen({
    Key? key,
    required this.isEditingMode,
    required this.selectedBookIds,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  State<FinishBookScreen> createState() => _FinishBookScreenState();
}

class _FinishBookScreenState extends State<FinishBookScreen> {

  late List<Map<String, dynamic>> allBooks = [];
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final viewModel = Provider.of<UserBookProvider>(context, listen: false);
      final booksData = await viewModel.fetchReadingBooks(context);
      booksData.sort((a, b) {
        final aUpdatedAt = a['userBook'].updatedAt;
        final bUpdatedAt = b['userBook'].updatedAt;
        return bUpdatedAt.compareTo(aUpdatedAt);
      });
      setState(() {
        allBooks = booksData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    // 완독한 책만 필터링
    List<int> completedIndexes = [];
    for (int i = 0; i < allBooks.length; i++) {
      final userBook = allBooks[i]['userBook'] as UserBookModel;
      if ((userBook.lastPosition ?? 0.0) >= 0.995) {
        completedIndexes.add(i);
      }
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
        child: GridView.builder(
          itemCount: completedIndexes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            int originalIndex = completedIndexes[index];
            final book = allBooks[originalIndex]['book'] as BookModel;
            final readingBook = allBooks[originalIndex]['userBook'] as UserBookModel;
            return BookProgress(
                book: book,
                readingBook: readingBook,
                isEditingMode: widget.isEditingMode,
                isSelected: widget.selectedBookIds.contains(book.title),
                onCheckboxChanged: (value) {
                  widget.onCheckboxChanged(book.title, value ?? false);
                },
                onTap: () async {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final userId = userProvider.user?.userId;

                  final snapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('reading_books')
                      .doc(book.title)
                      .get();

                  final data = snapshot.data();
                  final latestProgress = (data?['last_position'] as num?)?.toDouble() ?? 0.0;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookScreen(
                      title: book.title,
                      initialProgress: latestProgress,),
                    ),
                  );
                }
            );
          },
        ),
      ),
    );
  }
}