
// '완독 도서' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/shared/book_progress.dart';

import '../../model/book_model.dart';
import '../../model/user_book_model.dart';
import '../../provider/user_book_provider.dart';
import '../../shared/size_config.dart';

class FinishBookScreen extends StatefulWidget {
  const FinishBookScreen({super.key});

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
      if (allBooks[i]['userBook'].lastPosition == allBooks[i]['book'].totalPages) {
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
            return BookProgress(book: book, readingBook: readingBook);
          },
        ),
      ),
    );
  }
}