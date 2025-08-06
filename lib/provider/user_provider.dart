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

  void updateUserNickname(String newNickname) {
    if (_user != null) {
      _user = _user!.copyWith(nickname: newNickname);
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
