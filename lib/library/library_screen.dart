
// 서재 메인 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../shared/menu_bottom.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('닉네임의 서재'),
      ),
    );
  }
}
