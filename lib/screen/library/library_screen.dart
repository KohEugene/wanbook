
// 서재 메인 화면

import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? userId;
  bool isEditingMode = false;
  List<String> selectedBookIds = [];
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
        userId = userProvider.user?.userId ?? '사용자 아이디';
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void onCheckboxChanged(String bookId, bool isChecked) {
    setState(() {
      if (isChecked) {
        selectedBookIds.add(bookId);
      } else {
        selectedBookIds.remove(bookId);
      }
    });
  }

  Future<void> deleteSelectedBooks() async {
    if (selectedBookIds.isEmpty) {
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (final bookId in selectedBookIds) {
      batch.delete(firestore.collection('users')
          .doc(userId)
          .collection('reading_books')
          .doc(bookId)
      );
    }

    try {
      await batch.commit();
      setState(() {
        isEditingMode = false;
        selectedBookIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택한 책이 서재에서 삭제되었습니다.'), backgroundColor: Color(0xff0077FF)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 중 오류가 발생했습니다.'), backgroundColor: Color(0xffFF4F4F)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final nickname = userProvider.user?.nickname ?? '사용자';

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
      body: Stack(
        children: [
          Column(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isEditingMode = !isEditingMode;
                        selectedBookIds.clear();
                      });
                    },
                    style: ButtonStyle(
                      overlayColor: WidgetStateColor.resolveWith(
                              (states) => Colors.transparent),
                    ),
                    child: Text(
                      isEditingMode ? '취소' : '편집',
                      style: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                    ),
                    ),
                  ]
                ),
              Expanded(
                  child: TabBarView(
                      controller: tabController,
                      children: [
                        AllBookScreen(
                          isEditingMode: isEditingMode,
                          selectedBookIds: selectedBookIds,
                          onCheckboxChanged: onCheckboxChanged,
                        ),
                        ReadingBookScreen(
                          isEditingMode: isEditingMode,
                          selectedBookIds: selectedBookIds,
                          onCheckboxChanged: onCheckboxChanged,
                        ),
                        FinishBookScreen(
                          isEditingMode: isEditingMode,
                          selectedBookIds: selectedBookIds,
                          onCheckboxChanged: onCheckboxChanged,
                        ),
                      ],
                  )
              )
            ],
          ),
          if (isEditingMode)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: deleteSelectedBooks,
                    style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff0077FF),
                    backgroundColor: const Color(0xffCCE4FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    side: const BorderSide(color: Colors.transparent),
                  ),
                    child: const Text(
                      '선택 항목 삭제',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    )
                )
              ),
            )
        ]
      ),
    );
  }
}