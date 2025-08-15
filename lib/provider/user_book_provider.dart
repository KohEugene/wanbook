// 서재에 책 추가 & 사용자별 독서 정보 불러오기 함수
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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

  BookModel? longestReadBook;
  Duration? longestReadDuration;
  BookModel? shortestReadBook;
  Duration? shortestReadDuration;

  // 서재에 책 추가하기
  Future<bool> addBook(BuildContext context, {required String bookId}) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final now = DateTime.now();

    final docRef = _firestore
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .doc(bookId);

    final docSnapshot = await docRef.get();

    // 서재 중복 방지
    if (docSnapshot.exists) {
      return false;
    } else {
      final newBook = UserBookModel(
          bookId: bookId, lastPosition: 0, isCompleted: false,
          startedAt: now, updatedAt: now, completedAt: null,
          chatClick: 0,
      );

      await docRef.set(newBook.toMap(), SetOptions(merge: true));
    }
    notifyListeners();
    return true;
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

    final jsonString = await rootBundle.loadString('assets/book.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final bookList = jsonList.map((e) => BookModel.fromJson(e)).toList();

    List<Map<String, dynamic>> books = [];

    for (var logDoc in readLogSnapshot.docs) {
      final userBook = UserBookModel.fromDocument(logDoc);

      final book = bookList.firstWhere(
            (b) => b.title == userBook.bookId,
      );

      if (book.title.isNotEmpty) {
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

  // 가장 오래 읽은 책 & 짧게 읽은 책 계산하기
  Future<void> calculateBookStats(BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    final booksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .get();

    if (booksSnapshot.docs.isEmpty) {
      return;
    }

    longestReadBook = null;
    longestReadDuration = Duration.zero;
    shortestReadBook = null;
    shortestReadDuration = Duration(days: 9999);

    for (var doc in booksSnapshot.docs) {
      final bookData = doc.data() as Map<String, dynamic>;

      final startDate = (bookData['start_date'] as Timestamp).toDate();
      final endDate = (bookData['end_date'] as Timestamp).toDate();

      final duration = endDate.difference(startDate);

      if (duration > longestReadDuration!) {
        longestReadDuration = duration;
        longestReadBook = BookModel.fromDocument(doc); // Book 모델로 변환
      }

      if (duration < shortestReadDuration!) {
        shortestReadDuration = duration;
        shortestReadBook = BookModel.fromDocument(doc);
      }
    }

    notifyListeners();
  }
}