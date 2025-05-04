import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/profile/profile_screen.dart';
import 'package:wanbook/home/speechbubble.dart';

import '../shared/size_config.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // 진행도바 예시용 독서
  final List<String> titleList = [
    '데미안', '종의 기원', '소년이 온다', '이기적 유전자', '싯다르타', '침묵의 봄', '이방인', '아몬드', '눈먼 자들의 도시'
  ];

  final List<String> percentList = [
    '0%', '7%', '100%', '23%', '75%', '100%', '0%', '42%', '100%'
  ];

  final List<String> lastReadList = [
    '3시간 전', '16시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전', '24시간 전'
  ];

  final Map<String, Map<String, String>> bookInfoMap = {
    '데미안': {
      'author': '헤르만 헤세',
      'image': 'assets/images/b_damian.png',
    },
    '소년이 온다': {
      'author': '한강',
      'image': 'assets/images/b_boycome.png',
    },
    '종의 기원': {
      'author': '정유정',
      'image': 'assets/images/b_jong.png',
    },
    '이기적 유전자': {
      'author': '리처드 도킨스',
      'image': 'assets/images/b_gene.png',
    },
    '싯다르타': {
      'author': '헤르만 헤세',
      'image': 'assets/images/b_shitda.png',
    },
    '침묵의 봄': {
      'author': '레이첼 카슨',
      'image': 'assets/images/b_spring.png',
    },
    '이방인': {
      'author': '알베르 카뮈',
      'image': 'assets/images/b_gentile.png',
    },
    '아몬드': {
      'author': '손원평',
      'image': 'assets/images/b_amond.png',
    },
    '눈먼 자들의 도시': {
      'author': '사라마구',
      'image': 'assets/images/b_eye.png',
    },
  };

  // 책멍이 메시지
  final List<String> messages = [
    "오늘도 한 페이지씩 완독 향해 가볼까요? 아자아자!",
    "책멍이는 언제나 옆에 있어요! 한 페이지씩 차근차근 같이 가요!",
    "독서하는 닉네임님의 모습은 언제나 멋져요! 오늘도 파이팅!",
    "닉네임님, 지금까지 3권 읽었어요! 멋져요!",
  ];

  final Random random = Random();
  // 책멍이 말풍선 문구에서 문장부호 줄바꿈 함수 
  String splitMessageByPunctuation(String message) {
    return message
        .replaceAllMapped(RegExp(r'([.?!])\s*'), (match) => '${match.group(1)}\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    String randomMessage = messages[random.nextInt(messages.length)];
    String formattedMessage = splitMessageByPunctuation(randomMessage);

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
                SizedBox(height: 24),
                buildChaekmeongImage(formattedMessage),
                SizedBox(height: 24),
                buildReadingSection(),
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

  //책멍 이미지
  Widget buildChaekmeongImage(String message) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          // 말풍선
          Positioned(
            right: 120,
            top: 20,
            child: SpeechBubble(message: message),
          ),
          // 책멍이
          Positioned(
            right: 10,
            bottom: 0,
            child: Image.asset(
              'assets/images/home_Chaekmeong.png',
              height: 170,
            ),
          ),
        ],
      ),
    );
  }

  //진행도 섹션
  Widget buildReadingSection() {
    // 100% 미완독 책들의 인덱스만 추출
    List<int> incompleteIndexes = [];
    for (int i = 0; i < percentList.length; i++) {
      if (percentList[i] != '100%') {
        incompleteIndexes.add(i);
      }
    }

    if (incompleteIndexes.isEmpty) return SizedBox.shrink();

    // 랜덤으로 하나 선택
    int selectedIndex = incompleteIndexes[Random().nextInt(incompleteIndexes.length)];

    String title = titleList[selectedIndex];
    String author = bookInfoMap[title]?['author'] ?? '알 수 없음';
    String? coverImage = bookInfoMap[title]?['image'];
    String percentText = percentList[selectedIndex];
    double percentValue = double.parse(percentText.replaceAll('%', '')) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('아직 완독할 도서가 남았어요!',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                  overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
              ),
              child: Row(
                children: [
                  Text('독서하기', style: TextStyle(color: Color(0xff777777), fontWeight: FontWeight.w400, fontSize: 14)),
                  Icon(Icons.chevron_right_rounded, color: Color(0xff777777), size: 14),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xffF8F8F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverImage != null
                    ? Image.asset(coverImage, width: 110, height: 150, fit: BoxFit.cover)
                    : Container(width: 110, height: 150, color: Color(0xffD9D9D9)),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(author, style: TextStyle(color: Color(0xff777777), fontSize: 14)),
                    SizedBox(height: 16),
                    Text(
                      "이 책의 미리보기 내용 또는 소개 문장. 이 책의 미리보기 내용 또는 소개 문장. 이 책의 미리보기 내용 또는 소개 문장. 이 책의 미리보기 내용 또는 소개 문장.",
                      style: TextStyle(color: Color(0xff777777), fontSize: 14, fontWeight: FontWeight.w400),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),

                    // 진행도바
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(0xffE4E4E4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentValue, // 비율만큼만 파란색 
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff0077FF), // 파란색 진행 바
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          percentText,
                          style: TextStyle(fontSize: 12, color: Color(0xff0077FF)),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
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
