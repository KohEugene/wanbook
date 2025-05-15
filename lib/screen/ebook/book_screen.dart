// ebook 화면

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanbook/screen/aichat/chat_main_screen.dart';

import 'dart:async';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/screen/ebook/pngframeanimation.dart';
import 'package:wanbook/screen/library/all_book_screen.dart';


import 'package:pdfx/pdfx.dart';

class BookScreen extends StatefulWidget {
  final String title;
  
  const BookScreen({super.key, required this.title});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  double progress = 0.0;
  int? totalPages;

  // ebook 변수
  PdfController? _pdfController;
  PdfDocument? _pdfDocument;

  // UI 표시 여부
  bool showUI = true;

  // 한글 제목 -> 영어로 매핑
  String get pdfFileName {
    final Map<String, String> fileMap = {
      '데미안': 'demian.pdf',
      //어쩌꾸쩌어ㅉ우ㅉ뭄ㅈ검ㄱㅇㅁㅈㅇㅈㅁ
    };

    return fileMap[widget.title] ?? 'default.pdf';
  }
  
  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  // pdf 페이지 수 로딩
  Future<void> loadPdf() async {
    _pdfDocument = await PdfDocument.openAsset('assets/pdf/$pdfFileName');
    final count = await _pdfDocument!.pagesCount;

    setState(() {
      totalPages = count;
      _pdfController = PdfController(
        document: PdfDocument.openAsset('assets/pdf/$pdfFileName'),
        initialPage: 1,
      );
    });
  }

  // UI 사라졌다가 생겼다가
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

  // 클릭할 때 텍스트 배경 사이즈 변경되는 것 때문에 appbar 따로 뺌
  Widget buildCustomAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
        title: Text(widget.title), // 한글 제목 그대로 사용띠
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return MenuBottom(initialIndex: 2,);
            },));
          },
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
    );
  }

  // 멈춤 트래킹 책멍 아이콘
  Widget buildHintChaekmeongIcon(BuildContext context, String title) {
    return Positioned(
      // 여백없이 화면 오른쪽
      right: 0,
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
        child: Container(
          margin: const EdgeInsets.only(right: 0),
          child: PngFrameAnimation(
            basePath: 'assets/images/frames_/hint_Chaekmeong',
            frameCount: 7,
            interval: Duration(milliseconds: 80),
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }

  // pdf
  Widget buildBackground() {
    // pdf 없는 애들은 동글뱅이
    if (_pdfController == null || totalPages == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Positioned.fill(
      child: PdfView(
        controller: _pdfController!,
        scrollDirection: Axis.horizontal,
        onPageChanged: (page) {
          setState(() {
            progress = page / totalPages!;
          });
        },
      ),
    );
  }

  // 책 진행도 바
  Widget buildProgressSection(BuildContext context) {
    if (totalPages == null || _pdfController == null) {
      return const SizedBox.shrink(); // 진행도 바 숨기기 (로딩 중일 때)
    }

    // 구글이 clamp로 해야 버그 안 난대서 함,,,
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    int currentPage = (progress * totalPages!).round().clamp(1, totalPages!);

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
              value: currentPage.toDouble(),
              min: 1,
              max: totalPages!.toDouble(),
              onChanged: (value) {
                final page = value.round().clamp(1, totalPages!);
                setState(() {
                  progress = page / totalPages!;
                  _pdfController?.jumpToPage(page);
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
            child: SvgPicture.asset(
              'assets/images/icon_Chaekmeong.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
