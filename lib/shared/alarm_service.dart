import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AlarmService {
  // FCM 토큰 저장
  static Future<void> saveFcmToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
        "lastLogin": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true),
      );
    }

    // 토큰이 갱신되면 Firestore 업데이트
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'fcmToken': newToken},
        SetOptions(merge: true),
      );
    });
  }

  // 로그아웃 시 토큰 삭제
  static Future<void> clearFcmToken(String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'fcmToken': FieldValue.delete()});
  }
}
