
// 하단 메뉴바
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/screen/home/home_screen.dart';
import 'package:wanbook/screen/home/home_screen2.dart';
import 'package:wanbook/screen/library/library_screen.dart';
import 'package:wanbook/screen/profile/profile_screen.dart';
import 'package:wanbook/screen/search/search_screen.dart';

import '../provider/user_book_provider.dart';

class MenuBottom extends StatefulWidget {
  final int initialIndex;
  const MenuBottom({super.key, this.initialIndex = 0});

  @override
  State<MenuBottom> createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {

  DateTime? backPressedTime;
  late int selectedIndex;
  bool? showAlternateHome;

  late final List<Widget> _pages;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.initialIndex;

    Future.microtask(() async {
      final viewModel = Provider.of<UserBookProvider>(context, listen: false);
      final booksData = await viewModel.fetchReadingBooks(context);
      setState(() {
        showAlternateHome = booksData.isEmpty;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      showAlternateHome! ? HomeScreen2() : HomeScreen(),
      SearchScreen(),
      LibraryScreen(),
      ProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        DateTime nowTime = DateTime.now();
        if (backPressedTime == null ||
            nowTime.difference(backPressedTime!) > const Duration(seconds: 2)) {
          backPressedTime = nowTime;
          Fluttertoast.showToast(
              msg: '앱을 끄려면 한 번 더 눌러주세요.',
              fontSize: 14,
          );
        } else {
          SystemNavigator.pop(); // 앱 종료
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory
          ),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0xffE4E4E4),
                  blurRadius: 4
                )
              ]
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
                },

              type: BottomNavigationBarType.fixed,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              backgroundColor: Colors.white,

              unselectedLabelStyle: TextStyle(
                  color: Color(0xff777777),
                  fontSize: 10,
                  fontWeight: FontWeight.w400
              ),
              unselectedItemColor: Color(0xff777777),

              selectedLabelStyle: TextStyle(
                  color: Color(0xff0077FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600
              ),
              selectedItemColor: Color(0xff0077FF),

              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
                BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: '검색'),
                BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: '서재'),
                BottomNavigationBarItem(icon: Icon(Icons.perm_identity_rounded), label: '내 프로필')
              ],
            ),
          ),
        ),
      ),
    );
  }
}