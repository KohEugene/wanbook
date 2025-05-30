// 홈 2 (진행도서 X)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/screen/search/search_result_screen.dart';
import 'package:wanbook/screen/home/ArcProgressPainter.dart';

import '../../model/book_model.dart';
import '../../provider/user_provider.dart';
import '../../shared/book_basic.dart';
import '../../shared/size_config.dart';
import 'dart:math';
import 'dart:async';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreenState2();
}

class _HomeScreenState2 extends State<HomeScreen2> with TickerProviderStateMixin {
  // 책멍이 메시지
  final List<String> messages = [
    "오늘도 한 페이지씩\n완독 향해 가볼까요?\n아자아자!",
    "{nickname}님\n한 페이지씩 차근차근\n책멍이와 독서해요!",
    "독서하는 {nickname}님의 모습은\n언제나 멋져요!\n오늘도 파이팅!",
    "{nickname}님\n지금까지 3권 읽었어요!\n멋져요!",
    "{nickname}님\n지금의 한 페이지가\n완독을 만들어요!",
    "책멍이가 항상 응원해요!\n오늘도 한 걸음씩\n함께해요!",
    "조금씩 쌓이는 페이지가\n완독이라는\n큰 성취가 돼요!",
    "책멍이가 보고 있어요!\n{nickname}님의 꾸준함\n정말 대단해요!",
    "{nickname}님\n조금씩 차곡차곡,\n책 한 권 완성 중이에요!",
    "꾸준한 독서의 힘!\n책멍이가 끝까지 함께할게요!\n오늘도 한 장씩 함께 넘겨봐요!",
  ];

  // 인기도서 목록 예시용
  List<BookModel> books = [
    BookModel(title: '데미안', author: '헤르만 헤세', imagePath: 'assets/images/b_damian.png'),
    BookModel(title: '소년이 온다', author: '한강', imagePath: 'assets/images/b_boycome.png'),
    BookModel(title: '아몬드', author: '손원평', imagePath: 'assets/images/b_almond.png'),
    BookModel(title: '인간실격', author: '다자이 오사무', imagePath: 'assets/images/b_human.png'),
    BookModel(title: '노인과 바다', author: '어니스트 헤밍웨이', imagePath: 'assets/images/b_sea.png'),
  ];

  final Random random = Random();
  String? currentMessage;
  String nickname = '사용자';
  int? selectedIndex;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        nickname = userProvider.user?.nickname ?? '사용자';
        currentMessage = getRandomMessage();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool _isClicked = false;

  void updateMessage() {
    if (_isClicked || !mounted) return;

    setState(() {
      _isClicked = true;
    });

    _scaleController.stop();
    _scaleController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() {
        _isClicked = false;
        currentMessage = getRandomMessage();
      });
      _scaleController.repeat(reverse: true);
    });
  }

  String getRandomMessage() {
    final raw = messages[random.nextInt(messages.length)];
    return raw.replaceAll('{nickname}', nickname);
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
                SizedBox(height: 24),
                buildGreeting(),
                SizedBox(height: 8),
                buildChaekmeongImage(),
                SizedBox(height: 30),
                  buildBookSection(
                    '이런 책은 어떠신가요? 인기도서 목록',
                  ),
                SizedBox(height: 24),
                buildAttendanceSection(context),
                SizedBox(height: 24),
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
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
    );
  }

  Widget buildChaekmeongImage() {
    return SizedBox(
      height: 220,
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
                    SvgPicture.asset('assets/images/home_Chaekmeong_s.svg', height: 110),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: GestureDetector(
                            onTap: updateMessage,
                            child: SvgPicture.asset('assets/images/home_Chaekmeong.svg', height: 110),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(currentMessage ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xff777777))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 인기도서 목록
  Widget buildBookSection(String sectionTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(sectionTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return BookBasic(book: books[index], onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SearchResultScreen(searchKeyword: books[index].title),)
                );
              },);
            },
          ),
        )
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
            const Text('출석 체크', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MenuBottom(initialIndex: 3))),
              child: Row(
                children: const [
                  Text('더보기', style: TextStyle(color: Color(0xff777777), fontSize: 14)),
                  Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xff777777)),
                ],
              ),
            ),
          ],
        ),
        Text("$nickname님은 현재 독서량 ‘n권’으로 상위 n%예요!", style: const TextStyle(fontSize: 14, color: Color(0xff777777))),
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
              return Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: textColor),
                ),
                child: Text(days[index], style: TextStyle(color: textColor, fontSize: 10)),
              );
            }),
          ),
        ),
      ],
    );
  }
}
