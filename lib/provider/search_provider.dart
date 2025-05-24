// 검색 함수
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:wanbook/model/book_model.dart';

class SearchProvider with ChangeNotifier {
  bool _isLoading = false;
  BookModel? _searchResult;

  bool get isLoading => _isLoading;
  BookModel? get searchResult => _searchResult;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> searchBooks(String keyword) async {
    _isLoading = true;
    notifyListeners();

    final querySnapshot = await _firestore
        .collection('books')
        .where('title', isEqualTo: keyword)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _searchResult = BookModel.fromDocument(querySnapshot.docs.first);
    } else {
      _searchResult = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearResults() {
    _searchResult = null;
    notifyListeners();
  }
}