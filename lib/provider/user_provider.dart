// 유저 provider (프로필 사진은 Base64로 압축)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  String? get userId => _user?.userId;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void updateUserNickname(String newNickname) {
    if (_user != null) {
      _user = _user!.copyWith(nickname: newNickname);
      notifyListeners();
    }
  }

  Future<void> updateNicknameInDb(String newNickname) async {
    if (_user == null) return;
    final uid = _user!.userId;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
          'nickname': newNickname,
          'updated_at': FieldValue.serverTimestamp(),
        });

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser != null) {
      await authUser.updateDisplayName(newNickname);
    }

    updateUserNickname(newNickname);
  }

  void updateUserProfileImageBase64(String b64) {
    if (_user != null) {
      _user = _user!.copyWith(profileImageBase64: b64);
      notifyListeners();
    }
  }

  Future<void> updateProfileImageBase64InDb(String b64) async {
    if (_user == null) return;
    final uid = _user!.userId;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({
          'profile_image_base64': b64,
          'updated_at': FieldValue.serverTimestamp(),
        });

    updateUserProfileImageBase64(b64);
  }
}
