// 홈 2 (진행도서 X)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/search/search_result_screen.dart';
import 'package:wanbook/home/ArcProgressPainter.dart';

import '../shared/size_config.dart';
import 'dart:math';
import 'dart:async';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreenState2();
}

class _HomeScreenState2 extends State<HomeScreen2> {
  // 진행도바 예시용 독서
  final List<String> titleList = [
    '데미안', '오만과 편견', '소년이 온다', '변신', '노인과 바다', '인간실격', '이방인', '아몬드', '눈먼 자들의 도시'
  ];

  final List<String> percentList = [
    '0%', '7%', '100%', '23%', '75%', '100%', '0%', '42%', '100%'
  ];

  final List<String> lastReadList = [
    '3시간 전', '16시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전'
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

  // 책멍이 메시지
  final List<String> messages = [
    "오늘도 한 페이지씩\n완독 향해 가볼까요?\n아자아자!",
    "닉네임님\n한 페이지씩 차근차근\n책멍이와 독서해요!",
    "독서하는 닉네임님의 모습은\n언제나 멋져요!\n오늘도 파이팅!",
    "닉네임님\n지금까지 3권 읽었어요!\n멋져요!",
    "닉네임님\n지금의 한 페이지가\n완독을 만들어요!",
    "책멍이가 항상 응원해요!\n오늘도 한 걸음씩\n함께해요!",
    "조금씩 쌓이는 페이지가\n완독이라는\n큰 성취가 돼요!",
    "책 속에서 발견하는 즐거움\n오늘도 책멍이와 함께해요!",
    "책멍이가 보고 있어요!\n닉네임님의 꾸준함\n정말 대단해요!",
    "닉네임님\n조금씩 차곡차곡,\n책 한 권 완성 중이에요!",
    "꾸준한 독서의 힘!\n책멍이가 끝까지 함께할게요!\n오늘도 한 장씩 함께 넘겨봐요!",
  ];

  final Random random = Random();
  late String currentMessage;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    currentMessage = messages[random.nextInt(messages.length)];

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
        currentMessage = messages[random.nextInt(messages.length)];
      });
    });
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
                    '이런 책은 어떠신가요? 인기도서목록',
                    highlightTitle: '',
                    highlightAuthor: '',
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

  // 환영띠
  Widget buildGreeting() {
    return Text(
      "오늘 하루도 책멍이와 함께\n완독해봐요!",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  // 진행바 + 책멍 + 문구
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

  // 추천 도서
  Widget buildBookSection(String title, {
    required String highlightTitle,
    required String highlightAuthor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              if (index == 0) {
                return buildBookItem(
                  '데미안',
                  '헤르만 헤세',
                  imageAsset: 'assets/images/b_damian.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '데미안'),
                      ),
                    );
                  },
                );
              } else if (index == 1) {
                return buildBookItem(
                  '소년이 온다',
                  '한강',
                  imageAsset: 'assets/images/b_boycome.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '소년이 온다'),
                      ),
                    );
                  },
                );
              } else if (index == 2) {
                return buildBookItem(
                  '종의 기원',
                  '정유정',
                  imageAsset: 'assets/images/b_jong.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '종의 기원'),
                      ),
                    );
                  },
                );
              } else if (index == 3) {
                return buildBookItem(
                  '이기적 유전자',
                  '리처드 도킨스',
                  imageAsset: 'assets/images/b_gene.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '이기적 유전자'),
                      ),
                    );
                  },
                );
              } else if (index == 4) {
                return buildBookItem(
                  '침묵의 봄',
                  '레이첼 카슨',
                  imageAsset: 'assets/images/b_spring.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '침묵의 봄'),
                      ),
                    );
                  },
                );
              }  else {
                return buildBookItem(
                  '책 제목',
                  '저자 명',
                  imageAsset: null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultScreen(searchKeyword: '책 제목'),
                      ),
                    );
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }

  // 개별 책 항목
  Widget buildBookItem(String title, String author, {String? imageAsset, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 93,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Color(0xffD9D9D09)),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                  Text(author, style: const TextStyle(color: Color(0xff777777), fontSize: 12, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 출첵
  Widget buildAttendanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('출석 체크', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                  return MenuBottom(initialIndex: 3,);
                },));
              },
              style: ButtonStyle(
                  overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
              ),
              child: Row(
                children: [
                  Text('더보기', style: TextStyle(color: Color(0xff777777), fontWeight: FontWeight.w400, fontSize: 14)),
                  Icon(Icons.chevron_right_rounded, color: Color(0xff777777), size: 14),
                ],
              ),
            ),
          ],
        ),
        Text("닉네임님은 현재 독서량 ‘n권’으로 상위 n%예요!",
            style: TextStyle(fontSize: 14, color: Color(0xff777777), fontWeight: FontWeight.w400)),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              List<String> days = ['일', '월', '화', '수', '목', '금', '토'];
              bool isSelected = index < 2;
              Color textColor = isSelected ? Color(0xff0077FF) : Color(0xff777777);
              Color borderColor = isSelected ? Color(0xff0077FF) : Color(0xff777777);

              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w400),
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}
