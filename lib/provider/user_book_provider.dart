// 서재에 책 추가 & 사용자별 독서 정보 불러오기 함수
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_provider.dart';

import '../model/book_model.dart';
import '../model/user_book_model.dart';

class UserBookProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 서재에 책 추가하기
  Future<void> addBook(BuildContext context, {required String bookId}) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    final now = DateTime.now();

    final newBook = UserBookModel(
        bookId: bookId, lastPosition: 0, isCompleted: false,
        startedAt: now, updatedAt: now, completedAt: null
    );

    await _firestore
      .collection('users')
      .doc(user?.userId)
      .collection('reading_books')
      .doc(bookId)
      .set(newBook.toMap(), SetOptions(merge: true));
  }

  // 유저의 독서 목록 불러오기
  Future<List<Map<String, dynamic>>> fetchReadingBooks(BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    _isLoading = true;
    notifyListeners();

    final readLogSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .get();

    List<Map<String, dynamic>> books = [];

    for (var logDoc in readLogSnapshot.docs) {
      final userBook = UserBookModel.fromDocument(logDoc);

      final querySnapshot = await _firestore
          .collection('books')
          .where('title', isEqualTo: userBook.bookId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // BookModel 생성
        final book = BookModel.fromDocument(querySnapshot.docs.first);

        books.add({
          'book': book,
          'userBook': userBook,
        });
      }
    }

    _isLoading = false;
    notifyListeners();

    return books;
  }

  // 독서 정보 업데이트
}