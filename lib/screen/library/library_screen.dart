
// 서재 메인 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/screen/library/all_book_screen.dart';
import 'package:wanbook/screen/library/finish_book_screen.dart';
import 'package:wanbook/screen/library/reading_book_screen.dart';

import '../../provider/user_provider.dart';
import '../../shared/size_config.dart';


class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin{

  String? nickname;
  late TabController tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0
  );

  @override
  void initState() {
    tabController.addListener(() {
    },);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        nickname = userProvider.user?.nickname ?? '사용자';
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
                text: nickname,
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