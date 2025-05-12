
// 서재 메인 화면

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/library/all_book_screen.dart';
import 'package:wanbook/library/finish_book_screen.dart';
import 'package:wanbook/library/reading_book_screen.dart';

import '../shared/size_config.dart';


class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin{

  late TabController tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0
  );
  String? nickname;

  @override
  void initState() {
    tabController.addListener(() {
    },);
    loadNickname();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> loadNickname() async {
    final email = FirebaseAuth.instance.currentUser?.email;

    final querySnapshot = await FirebaseFirestore.instance
      .collection('users').where('email', isEqualTo: email).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      setState(() {
        nickname = userDoc.data()['nickname'] ?? '사용자';
      });
    }
  }

  final List<Widget> _pages = [
    AllBookScreen(),
    ReadingBookScreen(),
    FinishBookScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${nickname ?? '사용자'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff777777)
                )
              ),
              TextSpan(
                  text: '의 ',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black
                  )
              ),
              TextSpan(
                  text: '서재',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black
                  )
              )
            ]
          )
        ),
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: SizeConfig.screenWidth * 0.9,
              child: TabBar(
                controller: tabController,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
                labelColor: Color(0xff0077FF),
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600
                ),
                unselectedLabelColor: Color(0xff777777),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400
                ),
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                indicatorColor: Color(0xff0077FF),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: "전체 도서",),
                  Tab(text: "독서 중",),
                  Tab(text: "완독 도서",)
                ],
              ),
            ),
          ),
          Expanded(
              child: TabBarView(
                  controller: tabController,
                  children: _pages
              )
          )
        ],
      ),
    );
  }
}