// 서재 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class UserBookModel {
  final String bookId;
  final double? lastPosition;
  final bool isCompleted;
  final double? maxScroll;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int chatClick;
  final List<String> tags;

  const UserBookModel({
    required this.bookId,
    required this.lastPosition,
    required this.isCompleted,
    required this.startedAt,
    required this.updatedAt,
    this.completedAt,
    this.maxScroll,
    this.chatClick = 0,
    this.tags = const [],
  });

  factory UserBookModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<String> t = const [];
    if (data['tags'] is List) {
      t = List<String>.from(data['tags']);
    } else if (data['tag'] is String) {
      t = [data['tag'] as String];
    }
    return UserBookModel(
      bookId: data['book_id'] ?? '',
      lastPosition: (data['last_position'] as num?)?.toDouble(),
      isCompleted: data['is_completed'] ?? false,
      maxScroll: (data['max_scroll'] as num?)?.toDouble(),
      startedAt: (data['start_date'] as Timestamp).toDate(),
      updatedAt: (data['update_date'] as Timestamp).toDate(),
      completedAt: data['end_date'] != null
          ? (data['end_date'] as Timestamp).toDate()
          : null,
      chatClick: data['chat_click'] ?? 0,
      tags: t,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'last_position': lastPosition,
      'is_completed': isCompleted,
      'max_scroll': maxScroll,
      'start_date': Timestamp.fromDate(startedAt),
      'update_date': Timestamp.fromDate(updatedAt),
      'end_date': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'chat_click': chatClick,
      'tags': tags,
    };
  }
}
