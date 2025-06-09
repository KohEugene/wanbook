// 최근 검색어 provider
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/recentsearch_model.dart';

class RecentSearchProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _customUserId;

  void setUserId(String userId) {
    _customUserId = userId;
  }

  String get userId => _customUserId ?? '';

  Future<void> saveRecentSearch(String keyword) async {
    if (userId.isEmpty) return;

    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_searches')
        .doc(keyword);

    await docRef.set({
      'keyword': keyword,
      'searched_at': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  // 최근 검색어 가져오기
  Future<List<RecentSearchModel>> fetchRecentSearches({int limit = 10}) async {
    if (userId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_searches')
        .orderBy('searched_at', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => RecentSearchModel.fromMap(doc.data()))
        .toList();
  }

  // 최근 검색어 삭제
  Future<void> clearRecentSearches() async {
    if (userId.isEmpty) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_searches')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    notifyListeners();
  }
}
