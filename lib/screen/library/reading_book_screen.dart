
// '독서 중' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/book_model.dart';
import '../../model/user_book_model.dart';
import '../../provider/user_book_provider.dart';
import '../../shared/book_progress.dart';
import '../../shared/size_config.dart';

class ReadingBookScreen extends StatefulWidget {
  const ReadingBookScreen({super.key});

  @override
  State<ReadingBookScreen> createState() => _ReadingBookScreenState();
}

class _ReadingBookScreenState extends State<ReadingBookScreen> {

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

    // '100%'가 아닌 책
    List<int> readingIndexes = [];
    for (int i = 0; i < allBooks.length; i++) {
      if (allBooks[i]['userBook'].lastPosition != allBooks[i]['book'].totalPages) {
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
            final book = allBooks[originalIndex]['book'] as BookModel;
            final readingBook = allBooks[originalIndex]['userBook'] as UserBookModel;
            return BookProgress(book: book, readingBook: readingBook);
          },
        ),
      ),
    );
  }
}