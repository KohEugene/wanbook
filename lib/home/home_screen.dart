import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wanbook/home/cloud_icon.dart';
import 'package:wanbook/home/StepProgressBar.dart';
import 'package:wanbook/home/bone_icon.dart';

import 'package:wanbook/shared/menu_bottom.dart';
import 'package:wanbook/profile/profile_screen.dart';

import '../shared/size_config.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                SizedBox(height: 20),
                buildGreeting(),
                SizedBox(height: 24),
                buildChaekmeongImage(),
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

  /// 상단 완독
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

  // 책멍이 뼈다귀
  Widget buildChaekmeongImage() {
    return SizedBox(
      height: 300,
      width: double.infinity, // 💡 패딩 안쪽 공간을 모두 채움
      child: Stack(
        children: [
          // 생각 구름
          Positioned(
            left: 0,
            top: 0,
            child: CloudWidget(),
          ),

          //뼈다귀?
          Positioned(
            left: 16, 
            top: 32,
            child: SizedBox(
              width: 100,
              height: 100,
              child: SimpleBoneIcon(),
            ),
          ),

          //책멍
          Positioned(
            right: 10,
            bottom: 0,
            child: Image.asset(
              'assets/images/home_Chaekmeong.png',
              height: 170,
            ),
          ),
        ],
      )
    );
  }

  /// 최근 읽은 책
  Widget buildReadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '아직 완독할 도서가 남았어요!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                      overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
                  ),
              child: Row(
                  children: [
                    Text('독서하기', style: TextStyle(
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
                child: Image.asset(
                  'assets/images/boycome.png',
                  width: 110,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 독서 진행도
                      StepProgressBar(
                        totalSteps: 5,
                        currentStep: 2,
                      ), 
                    SizedBox(height: 8),
                    Text("소년이 온다",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)
                    ),
                    Text("한강 작가",
                        style: TextStyle(
                            color: Color(0xff777777),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,)
                    ),
                    SizedBox(height: 24),
                    Text(
                      "어머님, 그리고 당신은 멀리 북간도에 계십니다. 어머님, 그리고 당신은 멀리 북간도에 계십니다람쥐쥐쥐쥐쥐쥐.어머님, 그리고 당신은 멀리 북간도에 계십니다.",
                      style: TextStyle(
                          color: Color(0xff777777),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// 출석 체크
  Widget buildAttendanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '출석 체크',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              style: ButtonStyle(
                      overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent,)
                  ),
              child: Row(
                children: [
                  Text(
                    '더보기',
                    style: TextStyle(
                      color: Color(0xff777777),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xff777777),
                    size: 14,
                  )
                ],
              ),
            ),
          ],
        ),
        Text(
          "닉네임님은 현재 독서량 ‘n권’으로 상위 n%예요!",
          style: TextStyle(fontSize: 14, color: Color(0xff777777), fontWeight: FontWeight.w400,),
        ),
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
                  style: TextStyle(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            },),
          ),
        )
      ],
    );
  }
}
