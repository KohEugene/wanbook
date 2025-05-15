
// 배지 더보기 화면

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../shared/size_config.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {

  final List<bool> monthlyrecords = List.generate(12, (index) => index < 3,);
  final List<bool> achievements = List.generate(12, (index) => index < 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('독서 배지'),
        leading: IconButton(onPressed: () {
          Navigator.pop(context);  // 전 화면으로 돌아가기 위해서는 Navigator.pop 사용
        },
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth*0.05,
            ),
              child: Column(
                children: [
                  SizedBox(height: 16,),
                  allMonthlyRecord(),
                  SizedBox(height: 16,),
                  allAchieveBadge(achievements),
                  SizedBox(height: 16,),
                ],
              ),
            ),
          )
      ),
    );
  }

  // 배지 위젯
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

  Widget allMonthlyRecord() {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 400,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('월간 기록', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18),
          ),
          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 30,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
              List.generate(12, (index) {
                return recordBadge("${index + 1}월", !monthlyrecords[index]);
              }),
            )
          )
        ],
      ),
    );
  }

  Widget allAchieveBadge(List<bool> achievedList) {
    return Container(
      width: SizeConfig.screenWidth * 0.9,
      height: 400,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xffF8F8F8),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('업적 배지', style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18),
          ),
          SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 30,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children:
                List.generate(12, (index) {
                  return recordBadge("업적 ${index + 1}", !achievedList[index]);
                }),
            )
          )
        ],
      ),
    );
  }
}
