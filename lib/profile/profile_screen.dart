
// 내 프로필 메인 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanbook/aichat/chatlist_screen.dart';
import 'package:wanbook/profile/badge_screen.dart';
import 'package:wanbook/shared/pop_up.dart';

import '../shared/size_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final Map<String, Map<String, String>> bookInfoMap = {
    '침묵의 봄': {
      'author': '레이첼 카슨',
      'image': 'assets/images/b_spring.png',
    },
    '눈먼 자들의 도시': {
      'author': '사라마구',
      'image': 'assets/images/b_eye.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('내 프로필'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              // 양쪽 여백 넣기 (좌우, 상하 기준)
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.screenWidth*0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16,),
                  userInfoSection(),
                  SizedBox(height: 16,),
                  readingStatus(),
                  SizedBox(height: 16,),
                  chatWithChackmeong(),
                  SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: readingCard('가장 빨리 읽었어요', '침묵의 봄', '3시간 독서')),
                      SizedBox(width: 16,),
                      Expanded(child: readingCard('가장 오래 읽었어요', '눈먼 자들의 도시', '1개월 독서'))
                    ],
                  ),
                  SizedBox(height: 16,),
                  monthlyRecord(),
                  SizedBox(height: 16,),
                  achieveBadge(),
                  SizedBox(height: 16,),
                ],
              ),
            )
        ),
      )
    );
  }

  // 사용자 정보 섹션
  Widget userInfoSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xffD9D9D9),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffBABABA)
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return PopUp();
                              },
                          );
                        },
                        icon: Icon(Icons.edit, color: Color(0xff777777), size: 12,),
                      ),
                    ),
                  ),
                ]
            ),
            SizedBox(width: 16,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사용자 명', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)
                ),
                SizedBox(height: 4,),
                Text('@사용자 아이디', style: TextStyle(
                    color: Color(0xff777777),
                    fontWeight: FontWeight.w400,
                    fontSize: 14)
                )
              ],
            )
          ],
        ),
        SizedBox(
            width: 90,
            height: 36,
            child: OutlinedButton(onPressed: (){},
                style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xff777777),
                    backgroundColor: Color(0xffF8F8F8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)
                    ),
                    side: BorderSide(color: Colors.transparent),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                ),
                child: Text('로그아웃', style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12),
                )
            )
        ),
      ],
    );
  }

  Widget readingStatus() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, color: Color(0xff777777)),
          SizedBox(width: 16,),
          Text('15일째 5권', style: TextStyle(
              color: Color(0xff0077FF),
              fontWeight: FontWeight.w600,
              fontSize: 16),
          ),
          Text(' 독서 중이에요!', style: TextStyle(
              color: Color(0xff777777),
              fontWeight: FontWeight.w400,
              fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget chatWithChackmeong() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 166,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Stack(
        children: [
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: SvgPicture.asset('assets/images/list_Chaekmeong.svg', fit: BoxFit.cover,)
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('책멍이와의 대화', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                ),
                TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ChatlistScreen();
                  },));
                },
                  style: ButtonStyle(
                      overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
                  ),
                  child: Row(
                    children: [
                      Text('목록 보기', style: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                      ),
                      Icon(Icons.chevron_right_rounded,
                        color: Color(0xff777777),
                        size: 14,
                      )
                    ],
                  ),
                ),
              ]
          ),
        ],
      ),
    );
  }

  Widget readingCard(String section, String title, String duration) {
    final bookData = bookInfoMap[title];
    final author = bookData?['author'] ?? '작가 미상';
    final imagePath = bookData?['image'];

    return Container(
      width: SizeConfig.screenWidth * 0.45,
      height: 270,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section, style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16),
          ),
          SizedBox(height: 8,),
          Container(
            width: 100, height: 140,
            decoration: BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.circular(8),
                image: imagePath != null
                    ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                )
                    : null,
            ),
          ),
          SizedBox(height: 8,),
          Text(title, style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(author, style: TextStyle(
              color: Color(0xff777777),
              fontWeight: FontWeight.w400,
              fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(duration, style: TextStyle(
              color: Color(0xff777777),
              fontWeight: FontWeight.w400,
              fontSize: 11)
          )
        ],
      ),
    );
  }

  Widget recordBadge(String title, bool isLocked) {
    return SizedBox(
      width: 65,
      height: 93,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Color(0xffD9D9D9),
                  shape: BoxShape.circle),
              ),
              if (isLocked) ...[
                Positioned(
                  child: Icon(
                    Icons.lock,
                    color: Color(0xff777777),
                    size: 24
                  )
                )
              ],
            ]
          ),
          SizedBox(height: 8,),
          Text(title, style: TextStyle(
            color: Color(0xff777777),
            fontWeight: FontWeight.w400,
            fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget monthlyRecord() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 166,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('월간 기록', style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
                ),
                TextButton(onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BadgeScreen();
                  },));
                },
                  style: ButtonStyle(
                      overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
                  ),
                  child: Row(
                    children: [
                      Text('더보기', style: TextStyle(
                          color: Color(0xff777777),
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                      ),
                      Icon(Icons.chevron_right_rounded,
                        color: Color(0xff777777),
                        size: 14,
                      )
                    ],
                  ),
                ),
              ]
          ),
          SizedBox(height: 8,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                recordBadge('1월', false),
                recordBadge('2월', false),
                recordBadge('3월', false),
                recordBadge('4월', true)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget achieveBadge() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 166,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('업적 배지', style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
              ),
              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return BadgeScreen();
                },));
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
                ),
                child: Row(
                  children: [
                    Text('더보기', style: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                    ),
                    Icon(Icons.chevron_right_rounded,
                      color: Color(0xff777777),
                      size: 14,
                    )
                  ],
                ),
              ),
            ]
          ),
          SizedBox(height: 8,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                recordBadge('업적 명', false),
                recordBadge('업적 명', false),
                recordBadge('업적 명', false),
                recordBadge('업적 명', true)
              ],
            ),
          )
        ],
      ),
    );
  }
}