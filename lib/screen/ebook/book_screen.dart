import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:epubx/epubx.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/screen/aichat/chat_main_screen.dart';
import 'package:wanbook/screen/ebook/pngframeanimation.dart';

class BookScreen extends StatefulWidget {
  final String title;

  const BookScreen({super.key, required this.title});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  List<EpubChapter> chapters = [];
  bool isLoading = true;

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
    loadEpub();
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

  Future<void> loadEpub() async {
    try {
      final fullPath = 'assets/epub/$epubFileName';
      ByteData data = await DefaultAssetBundle.of(context).load(fullPath);
      Uint8List bytes = data.buffer.asUint8List();
      EpubBook book = await EpubReader.readBook(bytes);

      final allChapters = flattenChapters(book.Chapters ?? []);

      print('📖 총 챕터 수 (flattened): ${allChapters.length}');
      for (int i = 0; i < allChapters.length; i++) {
        print('📄 Chapter $i - 제목: ${allChapters[i].Title}, HTML 길이: ${allChapters[i].HtmlContent?.length ?? 0}');
      }

      setState(() {
        chapters = allChapters;
        isLoading = false;
      });
    } catch (e) {
      print("❌ EPUB 로드 실패: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          // 📚 텍스트는 맨 뒤에 배경처럼 깔림
          Positioned.fill(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final text = parse(chapter.HtmlContent ?? '').body?.text ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: SelectableText(
                          text,
                          style: const TextStyle(fontSize: 16, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
          ),

          // 📱 UI 전체 토글용 투명 레이어
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: toggleUI,
              child: const SizedBox.expand(),
            ),
          ),

          // ⬆️ AppBar 오버레이
          if (showUI)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: buildAppBar(context),
            ),

          // 📊 진행도 바 오버레이
          if (showUI)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: buildProgressBar(context),
            ),

          // 🐶 책멍이 아이콘
          if (showUI)
  Positioned(
    right: 24,
    bottom: 144,
    child: buildFloatingChaekmeongIcon(), // ✅ 여기서만 Positioned 써야 함
  ),


          // 힌트용 책멍이 애니메이션
          if (showHint) buildHintChaekmeongIcon(context, widget.title),
        ],
      ),
    ),
  );
}


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
              final target = chapters[index];
              final controller = ScrollController();
              controller.jumpTo(index * 1000); // 간이 처리
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


  Widget buildHintChaekmeongIcon(BuildContext context, String title) {
    return Positioned(
      right: 0,
      bottom: 120,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatMainScreen(title: title),
            ),
          );
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
