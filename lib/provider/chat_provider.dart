// 채팅 내역 provider

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/chatmessage_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 메시지 저장
  Future<void> sendMessage(String userId, String bookTitle, ChatMessageModel message) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(bookTitle)
        .collection('messages')
        .doc();

    await docRef.set(message.toMap());
  }

  // 메시지 실시간 가져오기
  Stream<List<ChatMessageModel>> getMessages(String userId, String bookTitle) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(bookTitle)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data()))
            .toList());
  }
}
