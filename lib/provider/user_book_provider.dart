// 서재에 책 추가 & 사용자별 독서 정보 불러오기 함수
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/model/reading_card_model.dart';
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
  Future<ReadingCardModel?> calculateBookStats(BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    final readLogSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.userId)
        .collection('reading_books')
        .get();

    if (readLogSnapshot.docs.isEmpty) {
      return null;
    }

    final jsonString = await rootBundle.loadString('assets/book.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    final bookList = jsonList.map((e) => BookModel.fromJson(e)).toList();

    UserBookModel? longestUserBook;
    Duration longestReadDuration = Duration.zero;

    UserBookModel? shortestUserBook;
    Duration shortestReadDuration = Duration(days: 9999);

    for (var logDoc in readLogSnapshot.docs) {
      final userBook = UserBookModel.fromDocument(logDoc);

      final startDate = userBook.startedAt;
      final endDate = userBook.completedAt;
      final duration = endDate?.difference(startDate);

      if (duration! > longestReadDuration) {
        longestReadDuration = duration;
        longestUserBook = userBook;
      }

      if (duration < shortestReadDuration) {
        shortestReadDuration = duration;
        shortestUserBook = userBook;
      }
    }

    BookModel? longestReadBook;
    BookModel? shortestReadBook;

    if (longestUserBook != null) {
      longestReadBook = bookList.firstWhere(
            (b) => b.title == longestUserBook!.bookId,
      );
    }

    if (shortestUserBook != null) {
      shortestReadBook = bookList.firstWhere(
            (b) => b.title == shortestUserBook!.bookId,
      );
    }

    //notifyListeners();

    return ReadingCardModel(
      longestReadBook: longestReadBook,
      longestReadDuration: longestReadDuration,
      shortestReadBook: shortestReadBook,
      shortestReadDuration: shortestReadDuration,
    );
  }
}