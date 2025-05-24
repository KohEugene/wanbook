// 사용자의 독서 상태 저장 모델 정의
import 'package:cloud_firestore/cloud_firestore.dart';

class UserBookModel {
  final String bookId;
  final int lastPosition;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  UserBookModel({
    required this.bookId,
    required this.lastPosition,
    required this.isCompleted,
    required this.startedAt,
    required this.updatedAt,
    this.completedAt
  });

  factory UserBookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserBookModel(
      bookId: data['book_id'] ?? '',
      lastPosition: data['last_position'] ?? 0,
      isCompleted: data['is_completed'] ?? false,
      startedAt: (data['start_date'] as Timestamp).toDate(),
      updatedAt: (data['update_date'] as Timestamp).toDate(),
      completedAt: data['end_date'] != null
          ? (data['end_date'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'last_position': lastPosition,
      'is_completed': isCompleted,
      'start_date': Timestamp.fromDate(startedAt),
      'update_date': Timestamp.fromDate(updatedAt),
      'end_date': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}