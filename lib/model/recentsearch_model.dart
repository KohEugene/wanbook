// 최근 검색어 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class RecentSearchModel {
  final String keyword;
  final DateTime searchedAt;

  RecentSearchModel({required this.keyword, required this.searchedAt});

  factory RecentSearchModel.fromMap(Map<String, dynamic> map) {
    return RecentSearchModel(
      keyword: map['keyword'] ?? '',
      searchedAt: (map['searched_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'keyword': keyword,
      'searched_at': searchedAt,
    };
  }
}
