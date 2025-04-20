
// 배지 더보기 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/profile/profile_screen.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('독서 배지'),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);  // 전 화면으로 돌아가기 위해서는 Navigator.pop 사용
        },
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      )
    );
  }
}
