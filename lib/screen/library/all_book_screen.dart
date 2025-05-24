
// '전체 도서' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/shared/book_progress.dart';
import '../../model/book_model.dart';
import '../../model/user_book_model.dart';
import '../../provider/user_book_provider.dart';
import '../../shared/size_config.dart';

class AllBookScreen extends StatefulWidget {
  const AllBookScreen({super.key});

  @override
  State<AllBookScreen> createState() => _AllBookScreenState();
}

class _AllBookScreenState extends State<AllBookScreen> {

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
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
        child: GridView.builder(
          itemCount: allBooks.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.48,
          ),
          itemBuilder: (context, index) {
            final book = allBooks[index]['book'] as BookModel;
            final readingBook = allBooks[index]['userBook'] as UserBookModel;
            return BookProgress(book: book, readingBook: readingBook);
          },
        ),
      ),
    );
  }
}
