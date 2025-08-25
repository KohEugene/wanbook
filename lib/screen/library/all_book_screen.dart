// '전체 도서' 탭 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/shared/book_progress.dart';
import 'package:wanbook/screen/ebook/book_screen.dart';
import 'package:wanbook/screen/question/purpose_screen.dart';
import 'package:wanbook/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            
            return BookProgress( 
              book: book,
              readingBook: readingBook,
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

                // 목적, 사전지식 필드 존재 여부 체크
                final hasPurposeField = data?.containsKey('purpose') ?? false;
                final hasPreknowledgeField = data?.containsKey('preknowledge') ?? false;

                if (latestProgress == 0.0) {
                  // last_position == 0 이지만 목적, 사전지식 필드가 존재하면 바로 BookScreen
                  if (hasPurposeField && hasPreknowledgeField) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookScreen(
                          title: book.title,
                          initialProgress: latestProgress, // 0.0 이어도 그대로 전달
                        ),
                      ),
                    );
                  } else {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReadingPurposeScreen(title: book.title),
                      ),
                    );
                  }
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookScreen(
                        title: book.title,
                        initialProgress: latestProgress,
                      ),
                    ),
                  );
                }

                // 돌아왔을 때 책 다시 불러오기
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
              },
            );
          },
        ),
      ),
    );
  }
}
