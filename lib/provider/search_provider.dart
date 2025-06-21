// 검색 함수
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:wanbook/model/book_model.dart';

class SearchProvider with ChangeNotifier {
  bool _isLoading = false;
  BookModel? _searchResult;

  bool get isLoading => _isLoading;
  BookModel? get searchResult => _searchResult;

  List<BookModel> _allBooks = [];

  // json 파일 로드 함수
  Future<void> loadBooksFromJson() async {
    final String jsonString = await rootBundle.loadString('assets/book.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allBooks = jsonList.map((e) => BookModel.fromJson(e)).toList();
  }

  Future<void> searchBooks(String keyword) async {
    _isLoading = true;
    notifyListeners();

    if (_allBooks.isEmpty) {
      await loadBooksFromJson();
    }

    _searchResult = _allBooks.firstWhere(
          (book) => book.title.contains(keyword),
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearResults() {
    _searchResult = null;
    notifyListeners();
  }
}