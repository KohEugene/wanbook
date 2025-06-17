// 사용자 provider 정의
import 'package:flutter/cupertino.dart';

import '../model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void updateUserNickname(String newNickname) {
    if (_user != null) {
      _user = _user!.copyWith(nickname: newNickname);
      notifyListeners(); // UI 자동 갱신
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
