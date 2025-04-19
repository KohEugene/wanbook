
// 내 프로필 메인 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../shared/menu_bottom.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('내 프로필'),
      ),
    );
  }
}
