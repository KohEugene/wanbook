
// 추천 도서 (태그 기반), 인기 도서
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../model/book_model.dart';

class RecommendProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BookModel> _allBooks = [];
  List<BookModel> _tagBasedBooks = [];
  List<BookModel> _popularBooks = [];

  List<BookModel> get tagBasedBooks => _tagBasedBooks;
  List<BookModel> get popularBooks => _popularBooks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadBooksFromJson() async {
    final jsonStr = await rootBundle.loadString('assets/book.json');
    final jsonList = json.decode(jsonStr) as List<dynamic>;
    _allBooks = jsonList.map((e) => BookModel.fromJson(e)).toList();
  }

  // 태그 기반 추천: 내 책 기록 + JSON
  Future<void> fetchTagBasedBooks(String userId) async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('reading_books')
        .get();

    final readBookIds = <String>{};
    final tagCount = <String, int>{};

    for (final doc in snapshot.docs) {
      final bookId = doc.id;
      readBookIds.add(bookId);

      final book = _allBooks.firstWhere(
            (b) => b.title == bookId,
      );

      if (book.tag != null) {
        tagCount[book.tag!] = (tagCount[book.tag!] ?? 0) + 1;
      }
    }

    if (tagCount.isEmpty) {
      _tagBasedBooks = [];
    } else {
      final topTag = tagCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final tag = topTag.first.key;

      // 해당 태그의 책 중 아직 안 읽은 책 추출
      List<BookModel> candidates = _allBooks
          .where((book) => book.tag == tag && !readBookIds.contains(book.title))
          .toList();

      // 랜덤 셔플 후 5개만 선택
      candidates.shuffle();
      _tagBasedBooks = candidates.take(5).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 인기 도서 추천: 여러 유저 기록 + JSON
  Future<void> fetchPopularBooks({int limit = 10}) async {
    final userSnapshots = await _firestore.collection('users').get();

    final freqMap = <String, int>{};

    for (var userDoc in userSnapshots.docs) {
      final booksSnapshot = await userDoc.reference.collection('reading_books').get();
      for (var doc in booksSnapshot.docs) {
        final bookId = doc.id;
        freqMap[bookId] = (freqMap[bookId] ?? 0) + 1;
      }
    }

    // 인기도순 정렬
    final sortedBookIds = freqMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topBookIds = sortedBookIds.take(limit).map((e) => e.key).toSet();

    // bookId에 해당하는 BookModel 찾기 (JSON에서)
    _popularBooks = _allBooks
        .where((book) => topBookIds.contains(book.title))
        .toList();

    notifyListeners();
  }
}

