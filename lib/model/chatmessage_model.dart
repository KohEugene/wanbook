// 채팅 내역 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String bookTitle; // 책 제목 추가

  ChatMessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.bookTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toUtc(),
      'bookTitle': bookTitle,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      bookTitle: map['bookTitle'] ?? '',
    );
  }
}