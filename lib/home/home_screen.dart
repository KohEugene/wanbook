// 홈 1 (진행도서 o)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/ebook/book_screen.dart';
import 'package:wanbook/home/ArcProgressPainter.dart';

import '../shared/size_config.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> titleList = [
    '데미안', '오만과 편견', '소년이 온다', '변신', '노인과 바다', '인간실격', '이방인', '아몬드', '눈먼 자들의 도시'
  ];

  final List<String> percentList = [
    '0%', '7%', '100%', '23%', '75%', '100%', '0%', '42%', '100%'
  ];

  final Map<String, Map<String, String>> bookInfoMap = {
    '데미안': {'author': '헤르만 헤세', 'image': 'assets/images/b_damian.png'},
    '소년이 온다': {'author': '한강', 'image': 'assets/images/b_boycome.png'},
    '오만과 편견': {'author': '제인 오스틴', 'image': 'assets/images/b_op.png'},
    '변신': {'author': '프란츠 카프카', 'image': 'assets/images/b_change.png'},
    '인간실격': {'author': '다자이 오사무', 'image': 'assets/images/b_human.png'},
    '노인과 바다': {'author': '어니스트 헤밍웨이', 'image': 'assets/images/b_sea.png'},
    '이방인': {'author': '알베르 카뮈', 'image': 'assets/images/b_gentile.png'},
    '아몬드': {'author': '손원평', 'image': 'assets/images/b_amond.png'},
    '눈먼 자들의 도시': {'author': '사라마구', 'image': 'assets/images/b_eye.png'},
  };

  final List<String> messages = [
    "오늘도 한 페이지씩\n완독 향해 가볼까요? 아자아자!",
    "닉네임님\n한 페이지씩 차근차근\n책멍이와 독서 해해요!",
    "독서하는 닉네임님의 모습은\n언제나 멋져요! 오늘도 파이팅!",
    "닉네임님\n지금까지 3권 읽었어요! 멋져요!",
  ];

  final Random random = Random();
  late String currentMessage;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    currentMessage = splitMessageByPunctuation(
      messages[random.nextInt(messages.length)],
    );

    // 미완독 도서 중 랜덤 1권 고정
    List<int> incompleteIndexes = [];
    for (int i = 0; i < percentList.length; i++) {
      if (percentList[i] != '100%') {
        incompleteIndexes.add(i);
      }
    }
    if (incompleteIndexes.isNotEmpty) {
      selectedIndex = incompleteIndexes[random.nextInt(incompleteIndexes.length)];
    }

    _startIdleAnimation();
  }

  @override
  void dispose() {
    _idleTimer?.cancel(); // 반드시 타이머 해제
    super.dispose();
  }

  // 애니메이션 변수
  double _scale = 1.0;
  bool _isClicked = false;
  Timer? _idleTimer;

  // 클릭x시에 애니메이션
  void _startIdleAnimation() {
    _idleTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isClicked) return;
      setState(() {
        _scale = _scale == 1.0 ? 1.05 : 1.0;
      });
    });
  }

  // 애니메이션 + 랜덤문구
  void updateMessage() {
    if (_isClicked || !mounted) return;

    setState(() {
      _isClicked = true;
      _scale = 1.2;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _scale = 1.0;
        _isClicked = false;
        currentMessage = splitMessageByPunctuation(
          messages[random.nextInt(messages.length)],
        );
      });
    });
  }

    // 책멍이 말풍선 문구에서 문장부호 줄바꿈 함수
  String splitMessageByPunctuation(String message) {
    return message
        .replaceAllMapped(RegExp(r'([.?!])\s*'), (match) => '${match.group(1)}\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                buildGreeting(),
                const SizedBox(height: 16),
                buildChaekmeongImage(),
                const SizedBox(height: 24),
                buildReadingSection(context),
                const SizedBox(height: 24),
                buildAttendanceSection(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGreeting() {
    return const Text(
      "오늘 하루도 책멍이와 함께\n완독해봐요!",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  // 진행바 + 책멍 + 문구구
  Widget buildChaekmeongImage() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: ArcProgressPainter(progress: 0.75),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 고정된 밑그림
                    SvgPicture.asset(
                      'assets/images/home_Chaekmeong_s.svg',
                      height: 110, // 고정 크기
                    ),
                    // 애니메이션 적용된 책멍이
                    AnimatedScale(
                      scale: _scale,
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: updateMessage,
                        child: SvgPicture.asset(
                          'assets/images/home_Chaekmeong.svg',
                          height: 110,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currentMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff777777),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget buildReadingSection(BuildContext context) {
    if (selectedIndex == null) return const SizedBox.shrink();

    String title = titleList[selectedIndex!];
    String author = bookInfoMap[title]?['author'] ?? '알 수 없음';
    String? coverImage = bookInfoMap[title]?['image'];
    String percentText = percentList[selectedIndex!];
    double percentValue = double.parse(percentText.replaceAll('%', '')) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('아직 완독할 도서가 남았어요!',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookScreen(title: title)),
                );
              },
              child: Row(
                children: const [
                  Text('독서하기', style: TextStyle(color: Color(0xff777777), fontSize: 14)),
                  Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xff777777)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverImage != null
                    ? Image.asset(coverImage, width: 110, height: 150, fit: BoxFit.cover)
                    : Container(width: 110, height: 150, color: const Color(0xffD9D9D9)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(author, style: const TextStyle(color: Color(0xff777777), fontSize: 14)),
                    const SizedBox(height: 16),
                    const Text(
                      "이 책의 내용 또는 다른 무언가가가가가다람쥐지지지지지지이 책의 내용 또는 다른 무언가가가가가다람쥐지지지지지지이 책의 내용 또는 다른 무언가가가가가다람쥐지지지지지지",
                      style: TextStyle(color: Color(0xff777777), fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xffE4E4E4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentValue,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff0077FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          percentText,
                          style: const TextStyle(fontSize: 12, color: Color(0xff0077FF)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAttendanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('출석 체크',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MenuBottom(initialIndex: 3)),
                );
              },
              child: Row(
                children: const [
                  Text('더보기', style: TextStyle(color: Color(0xff777777), fontSize: 14)),
                  Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xff777777)),
                ],
              ),
            ),
          ],
        ),
        const Text("닉네임님은 현재 독서량 ‘n권’으로 상위 n%예요!",
            style: TextStyle(fontSize: 14, color: Color(0xff777777))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
              bool isSelected = index < 2;
              Color textColor = isSelected ? const Color(0xff0077FF) : const Color(0xff777777);
              Color borderColor = textColor;

              return Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  days[index],
                  style: TextStyle(color: textColor, fontSize: 10),
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}
