// ebook 화면

import 'package:flutter/material.dart';
import 'package:wanbook/aichat/chat_main_screen.dart';

import 'dart:async';

import 'package:wanbook/shared/menu_bottom.dart';

class BookScreen extends StatefulWidget {
  final String title;
  
  const BookScreen({super.key, required this.title});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  double progress = 0.51;
  final int totalPages = 500;

  // UI 표시 여부
  bool showUI = true;

  void toggleUI() {
    setState(() {
      showUI = !showUI;
      showHint = false;
    });

    if (!showUI) {
      startInactivityTimer(); // AppBar 숨겨졌으면 타이머 시작
    } else {
      cancelInactivityTimer(); // AppBar 보이면 타이머 종료
    }
  }

  // 임시 멈춤 트래킹
  bool showHint = false;
  Timer? _inactivityTimer;

  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    if (!showUI) {
      _inactivityTimer = Timer(Duration(seconds: 10), () {
        setState(() {
          showHint = true;
        });
        print("hint 책멍이 등장!");
      });
    }
  }

  void cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void initState() {
      super.initState();
      if (!showUI) {
        startInactivityTimer();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            toggleUI();
          },
          child: Stack(
            children: [
              buildBackground(),
              if (showUI) buildCustomAppBar(context),
              if (showUI) buildProgressSection(context),
              if (showUI) buildFloatingChaekmeongIcon(),
              if (showHint) buildHintChaekmeongIcon(context, widget.title),
            ],
          ),
        ),
      ),
    );
  }

  // 클릭할때 텍스트 배경 사이즈 변경되는 것때문에 appbar 따로 뺌
  Widget buildCustomAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
    );
  }

  // 멈춤 트래킹 책멍 아이콘
  Widget buildHintChaekmeongIcon(BuildContext context, String title) {
    return Positioned(
      right: 24,
      bottom: 120,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatMainScreen(title: title),
            ),
          );
        },
        child: Image.asset(
          'assets/images/hint_Chaekmeong.png',
          width: 100,
          height: 100,
        ),
      ),
    );
  }

  // 뒤에 텍스트 이미지
  Widget buildBackground() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned.fill(
      child: Center(
        child: Image.asset(
          'assets/images/t_damian.png',
          height: screenHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // 책 진행도 바
  Widget buildProgressSection(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    int currentPage = (progress * totalPages).round();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: progress,
              onChanged: (value) {
                setState(() {
                  progress = value;
                });
              },
              activeColor: Color(0xff0077FF),
              inactiveColor: Color(0xffE4E4E4),
            ),
            Text(
              '${(progress * 100).round()}% ($currentPage / $totalPages p)',
              style: TextStyle(color: Color(0xff777777), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 책멍이 AI 챗봇 아이콘
  Widget buildFloatingChaekmeongIcon() {
    return Positioned(
      right: 24,
      bottom: 120,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatMainScreen(title: widget.title), // 책 제목 전달
            ),
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xff777777)),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Image.asset(
              'assets/images/icon_Chaekmeong.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
