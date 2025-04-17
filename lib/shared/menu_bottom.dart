
// 하단 메뉴바

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar (
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: '서재'),
        BottomNavigationBarItem(icon: Icon(Icons.perm_identity_rounded), label: '내 프로필')
      ],
    );
  }

}