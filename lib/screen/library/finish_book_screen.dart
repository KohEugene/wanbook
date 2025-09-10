
// '완독 도서' 탭 화면

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/shared/book_progress.dart';

import '../../model/book_model.dart';
import '../../model/user_book_model.dart';
import '../../provider/user_provider.dart';
import '../../shared/size_config.dart';
import '../ebook/book_screen.dart';

class FinishBookScreen extends StatefulWidget {
  final bool isEditingMode;
  final List<String> selectedBookIds;
  final void Function(String bookId) onSelect;

  const FinishBookScreen({
    Key? key,
    required this.isEditingMode,
    required this.selectedBookIds,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<FinishBookScreen> createState() => _FinishBookScreenState();
}

class _FinishBookScreenState extends State<FinishBookScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05, vertical: 16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('reading_books')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xff0077FF)));
            }
            return FutureBuilder<String>(
                future: rootBundle.loadString('assets/book.json'),
                builder: (context, jsonSnapshot) {
                  if (!jsonSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xff0077FF)));
                  }

                  final List<dynamic> jsonList = json.decode(jsonSnapshot.data!);
                  final bookList = jsonList.map((e) => BookModel.fromJson(e)).toList();

                  final booksData = snapshot.data!.docs.map((logDoc) {
                    final data = logDoc.data() as Map<String, dynamic>? ?? {};
                    final userBook = UserBookModel.fromDocument(logDoc);

                    final book = bookList.firstWhere(
                          (b) => b.title == userBook.bookId,
                      orElse: () => BookModel(
                        title: userBook.bookId,
                        author: '미상',
                      ),
                    );

                    return {
                      'book': book,
                      'userBook': userBook,
                      'lastPosition': (data['last_position'] as num?)?.toDouble() ?? 0.0,
                      'hasPurpose': data.containsKey('purpose'),
                      'hasPreknowledge': data.containsKey('preknowledge'),
                    };
                  }).toList();

                  List<int> completedIndexes = [];
                  for (int i = 0; i < booksData.length; i++) {
                    final userBook = booksData[i]['userBook'] as UserBookModel;
                    if ((userBook.lastPosition ?? 0.0) >= 0.995) {
                      completedIndexes.add(i);
                    }
                  }

                  booksData.sort((a, b) {
                    final aUpdated = (a['userBook'] as UserBookModel).updatedAt;
                    final bUpdated = (b['userBook'] as UserBookModel).updatedAt;
                    return bUpdated.compareTo(aUpdated);
                  });
                return GridView.builder(
                  itemCount: completedIndexes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.49,
                  ),
                  itemBuilder: (context, index) {
                    int originalIndex = completedIndexes[index];
                    final book = booksData[originalIndex]['book'] as BookModel;
                    final readingBook = booksData[originalIndex]['userBook'] as UserBookModel;
                    final latestProgress = booksData[originalIndex]['lastPosition'] as double;

                    return BookProgress(
                        book: book,
                        readingBook: readingBook,
                        isEditingMode: widget.isEditingMode,
                        isSelected: widget.selectedBookIds.contains(book.title),
                        onSelect: () => widget.onSelect(book.title),
                        onTap: () async {
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
                );
              }
            );
          }
        ),
      ),
    );
  }
}