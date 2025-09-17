// '독서 중' 탭 화면

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/book_model.dart';
import '../../model/user_book_model.dart';
import '../../provider/user_provider.dart';
import '../../shared/book_progress.dart';
import '../../shared/size_config.dart';
import '../ebook/book_screen.dart';
import '../question/purpose_screen.dart';

class ReadingBookScreen extends StatefulWidget {
  final bool isEditingMode;
  final List<String> selectedBookIds;
  final void Function(String bookId) onSelect;

  const ReadingBookScreen({
    Key? key,
    required this.isEditingMode,
    required this.selectedBookIds,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<ReadingBookScreen> createState() => _ReadingBookScreenState();
}

class _ReadingBookScreenState extends State<ReadingBookScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.screenWidth * 0.05,
          vertical: 16,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('reading_books')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xff0077FF)),
              );
            }

            return FutureBuilder<String>(
              future: rootBundle.loadString('assets/book.json'),
              builder: (context, jsonSnapshot) {
                if (!jsonSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xff0077FF)),
                  );
                }

                final List<dynamic> jsonList =
                    json.decode(jsonSnapshot.data!);
                final bookList =
                    jsonList.map((e) => BookModel.fromJson(e)).toList();

                // Firestore → 데이터 매핑
                final allRows = snapshot.data!.docs.map((logDoc) {
                  final data =
                      (logDoc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
                  final userBook = UserBookModel.fromDocument(logDoc);

                  final book = bookList.firstWhere(
                    (b) => b.title == userBook.bookId,
                    orElse: () => BookModel(
                      title: userBook.bookId,
                      author: '미상',
                    ),
                  );

                  final lastPos =
                      (userBook.lastPosition ?? (data['last_position'] as num?)?.toDouble()) ??
                          0.0;

                  return {
                    'book': book,
                    'userBook': userBook,
                    'lastPosition': lastPos,
                    'isCompleted': (data['is_completed'] as bool?) ?? false,
                    'hasPurpose': data.containsKey('purpose'),
                    'hasPreknowledge': data.containsKey('preknowledge'),
                  };
                }).toList();

                final booksData =
                    allRows.where((row) => row['isCompleted'] == false).toList();

                // 최신 업데이트순 정렬
                booksData.sort((a, b) {
                  final aUpdated = (a['userBook'] as UserBookModel).updatedAt;
                  final bUpdated = (b['userBook'] as UserBookModel).updatedAt;
                  return bUpdated.compareTo(aUpdated);
                });

                if (booksData.isEmpty) {
                  return const Center(child: Text('읽는 중인 도서가 아직 없어요.'));
                }

                return GridView.builder(
                  itemCount: booksData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.49,
                  ),
                  itemBuilder: (context, index) {
                    final book = booksData[index]['book'] as BookModel;
                    final readingBook =
                        booksData[index]['userBook'] as UserBookModel;
                    final latestProgress =
                        booksData[index]['lastPosition'] as double;
                    final hasPurposeField =
                        booksData[index]['hasPurpose'] as bool;
                    final hasPreknowledgeField =
                        booksData[index]['hasPreknowledge'] as bool;

                    return BookProgress(
                      book: book,
                      readingBook: readingBook,
                      isEditingMode: widget.isEditingMode,
                      isSelected:
                          widget.selectedBookIds.contains(book.title),
                      onSelect: () => widget.onSelect(book.title),
                      onTap: () async {
                        if (latestProgress == 0.0) {
                          if (hasPurposeField && hasPreknowledgeField) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookScreen(
                                  title: book.title,
                                  initialProgress: latestProgress,
                                ),
                              ),
                            );
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReadingPurposeScreen(title: book.title),
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
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
