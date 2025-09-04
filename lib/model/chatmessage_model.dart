// 채팅 내역 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String bookTitle;

  final String category;      
  final bool isBlocked;      
  final bool relatedToBook;  
  final String guardReason;    
  final String otherBookHint; 

  ChatMessageModel({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.bookTitle,
    this.category = 'on_topic',
    this.isBlocked = false,
    this.relatedToBook = true,
    this.guardReason = '',
    this.otherBookHint = '',
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toUtc(),
      'bookTitle': bookTitle,
    };

    if (senderId != 'bot') {
      map.addAll({
        'category': category,
        'isBlocked': isBlocked,
        'relatedToBook': relatedToBook,
        'guardReason': guardReason,
        'otherBookHint': otherBookHint,
      });
    }

    return map;
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      bookTitle: map['bookTitle'] ?? '',
      category: map['category'] ?? 'on_topic',
      isBlocked: (map['isBlocked'] ?? false) as bool,
      relatedToBook: (map['relatedToBook'] ?? true) as bool,
      guardReason: map['guardReason'] ?? '',
      otherBookHint: map['otherBookHint'] ?? '',
    );
  }
}
