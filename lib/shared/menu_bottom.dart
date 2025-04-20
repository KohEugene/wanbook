
// 하단 메뉴바

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanbook/home/home_screen.dart';
import 'package:wanbook/library/library_screen.dart';
import 'package:wanbook/profile/profile_screen.dart';
import 'package:wanbook/search/search_screen.dart';

class MenuBottom extends StatefulWidget {
  const MenuBottom({super.key});

  @override
  State<MenuBottom> createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom> {
  
  int selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen()
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: '서재'),
              BottomNavigationBarItem(icon: Icon(Icons.perm_identity_rounded), label: '내 프로필')
            ],
          ),
        ),
      ),
    );
  }
}