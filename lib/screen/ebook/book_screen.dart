import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:epubx/epubx.dart';

import 'dart:async';
import 'dart:typed_data';
import '../../provider/user_provider.dart';

import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/screen/aichat/chat_main_screen.dart';
import 'package:wanbook/screen/ebook/pngframeanimation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookScreen extends StatefulWidget {
  final String title;
  final double initialProgress;

  const BookScreen({super.key, required this.title, this.initialProgress = 0.0});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> with WidgetsBindingObserver{
  final ScrollController _scrollController = ScrollController();

  late String userId;
  late String nickname;
  double lastSavedProgress = 0.0;
  
  List<EpubChapter> chapters = [];
  bool isLoading = true;
  bool _justJumped = false;
  double pageCount = 1.0;

  double progress = 0.0;
  bool showUI = true;
  bool showHint = false;
  Timer? _inactivityTimer;

  String get epubFileName {
    final Map<String, String> fileMap = {
      '데미안': 'demian.epub',
      '변신': 'metamorphosis.epub',
      '인간실격': 'nolongerhuman.epub',
      '이방인': 'thestranger.epub',
      '노인과 바다': 'theoldmanandthesea.epub'
    };
    return fileMap[widget.title] ?? 'default.epub';
  }  

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        nickname = userProvider.user?.nickname ?? '사용자';
        userId = userProvider.user?.userId ?? 'guest';
      });
    });

    loadEpub();
    WidgetsBinding.instance.addObserver(this);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final newProgress = (current / maxScroll).clamp(0.0, 1.0);

      setState(() {
        progress = newProgress;
      });

      if (_justJumped) {
        _justJumped = false;
        return;
      }

      if ((progress - lastSavedProgress).abs() > 0.01) {
        lastSavedProgress = progress;
        saveProgress(progress);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    cancelInactivityTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 진행률 저장
  void saveProgress(double rawProgress) async {
    final rounded = double.parse((rawProgress).toStringAsFixed(4)); // 소수점 4자리만 저장
    print("saveProgress 호출됨: $rounded");

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reading_books')
          .doc(widget.title)
          .update({
            'last_position': rounded,
            'update_date': FieldValue.serverTimestamp(),
          });
      print("Firestore에 진행률 저장됨: $rounded");
    } catch (e) {
      print("Firestore 저장 실패: $e");
    }
  }

  List<EpubChapter> flattenChapters(List<EpubChapter> chapters) {
    List<EpubChapter> result = [];
    for (var chapter in chapters) {
      result.add(chapter);
      if (chapter.SubChapters?.isNotEmpty == true) {
        result.addAll(flattenChapters(chapter.SubChapters!));
      }
    }
    return result;
  }

  // 진행률, epub 불러오기
  Future<void> loadEpub() async {
    try {
      final fullPath = 'assets/epub/$epubFileName';
      ByteData data = await DefaultAssetBundle.of(context).load(fullPath);
      Uint8List bytes = data.buffer.asUint8List();
      EpubBook book = await EpubReader.readBook(bytes);

      // Firestore에서 page_count 불러오기
      final bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: widget.title)
          .get();

      if (bookDoc.docs.isNotEmpty) {
        final data = bookDoc.docs.first.data();
        final count = data['page_count'];

        if (count is double) {
          pageCount = count;
        } else if (count is int) {
          pageCount = count.toDouble();
        } else {
          pageCount = 1;
        }
      }

      setState(() {
        chapters = flattenChapters(book.Chapters ?? []);
        isLoading = false;
      });

      // page_count 기준으로 스크롤 위치 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final position = (_scrollController.position.maxScrollExtent * widget.initialProgress)
              .clamp(0.0, _scrollController.position.maxScrollExtent);
          _scrollController.jumpTo(position);
          _justJumped = true;
        }
      });

      await scrollToInitialPosition();

    } catch (e) {
      print("EPUB 또는 Firestore 로드 실패: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 책 렌더링 대기 (서재 -> ebook시 책 내용이 진행률과는 전혀 다른 부분이 보여서 추가)
  Future<void> scrollToInitialPosition() async {
    double lastExtent = 0;
    int stableCount = 0;

    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(milliseconds: 100));

      if (!_scrollController.hasClients) continue;

      final currentExtent = _scrollController.position.maxScrollExtent;

      if ((currentExtent - lastExtent).abs() < 10) {
        stableCount++;
        if (stableCount >= 3) break;
      } else {
        stableCount = 0;
      }

      lastExtent = currentExtent;
    }

    final max = _scrollController.position.maxScrollExtent;
    final target = (max * widget.initialProgress).clamp(0.0, max);

    _scrollController.jumpTo(target);
    _justJumped = true;

    // Firestore에 유저마다 책 maxScrollExtent 저장
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reading_books')
          .doc(widget.title)
          .update({
            'max_scroll': max,
            'update_date': FieldValue.serverTimestamp(),
          });
      print("Firestore에 max_scroll 저장됨: $max");
    } catch (e) {
      print("max_scroll 저장 실패: $e");
    }
  }

  // UI 숨기기
  void toggleUI() {
    setState(() {
      showUI = !showUI;
      showHint = false;
    });

    if (!showUI) {
      startInactivityTimer();
    } else {
      cancelInactivityTimer();
    }
  }

  // UI 숨겨질 시 힌트 책멍 타이머
  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: 7), () {
      setState(() {
        showHint = true;
      });
    });
  }

  void cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 이북페이지로 다시 돌아올때 힌트 책멍이 없애기
    if (state == AppLifecycleState.resumed) {
      setState(() {
        showHint = false; // 힌트 숨기기
      });
      if (!showUI) {
        startInactivityTimer(); // 다시 타이머 시작
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final text = parse(chapter.HtmlContent ?? '').body?.text ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: SelectableText(
                      text,
                      style: const TextStyle(fontSize: 18, height: 1.6),
                      textAlign: TextAlign.left,
                    ),
                  );
                },
              )
            ),

            // UI 전체 토글용 투명 레이어
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: toggleUI,
                child: const SizedBox.expand(),
              ),
            ),

            // appbar
            if (showUI)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: buildAppBar(context),
              ),

            // progress bar
            if (showUI)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: buildProgressBar(context),
              ),

            // icon
            if (showUI)
              Positioned(
                right: 24,
                bottom: 144,
                child: buildFloatingChaekmeongIcon(),
              ),

            // 힌트용 책멍이 애니메이션
            if (showHint) buildHintChaekmeongIcon(context, widget.title),
          ],
        ),
      ),
    );
  }

  // 앱바
  Widget buildAppBar(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.title),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MenuBottom(initialIndex: 2)),
              );
            },
          ),
        ),
      ),
    );
  }

  // 진행도바
  Widget buildProgressBar(BuildContext context) {
    if (chapters.isEmpty) return const SizedBox.shrink();

    final chapterCount = chapters.length;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: progress,
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                progress = value;
              });
            },
            onChangeEnd: (value) {
              final index = (value * chapterCount).floor().clamp(0, chapterCount - 1);
              _scrollController.jumpTo(index * 1000);
            },
            activeColor: const Color(0xff0077FF),
            inactiveColor: const Color(0xffE4E4E4),
          ),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(color: Color(0xff777777), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 책멍 챗봇 아이콘콘
  Widget buildFloatingChaekmeongIcon() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMainScreen(title: widget.title),
          ),
        );
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xff777777)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SvgPicture.asset(
            'assets/images/icon_Chaekmeong.svg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // 힌트 책멍 아이콘
  Widget buildHintChaekmeongIcon(BuildContext context, String title) {
    return Positioned(
      right: 0,
      bottom: 120,
      child: GestureDetector(
        onTap: () {
          // Navigator 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatMainScreen(title: title),
            ),
          ).then((_) {
            // 돌아왔을 때 처리
            setState(() {
              showHint = false;
            });
            if (!showUI) {
              startInactivityTimer();
            }
          });
        },
        child: PngFrameAnimation(
          basePath: 'assets/images/frames_/hint_Chaekmeong',
          frameCount: 7,
          interval: const Duration(milliseconds: 80),
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
