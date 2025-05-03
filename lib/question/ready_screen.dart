// 모든 단계 완료 화면
import 'package:flutter/material.dart';

class ReadyScreen extends StatefulWidget {
  const ReadyScreen({super.key});

  @override
  State<ReadyScreen> createState() => _ReadyScreenState();
}

class _ReadyScreenState extends State<ReadyScreen> {

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('준비 완료'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 16),
              buildProgressBar(currentStep: 4),
              const SizedBox(height: 32),
              buildHeaderText(),
              const SizedBox(height: 60),
              Expanded(child: buildImage()),
              //const Spacer(),
              buildBottomButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 텍스트
  Widget buildHeaderText() {
    return Column(
      children: [
        Text(
          '모든 단계가 끝났어요!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(
          '이제 독서를 시작해볼까요?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff777777)),
        ),
      ],
    );
  }

  // 이미지
  Widget buildImage() {
    return Center(
      child: Image.asset(
            'assets/images/finish_Chaekmeong.png',
        width: 200,
        height: 200,
      ),
    );
  }

  // 하단 버튼 한개
  Widget buildBottomButtons() {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton(
      onPressed: () {
              // ebook화면으로로
            },
        style: OutlinedButton.styleFrom(
          backgroundColor: Color(0xffCCE4FF),
          foregroundColor: Color(0xff0077FF),
          padding: EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          side: BorderSide(color: Colors.transparent),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text('독서하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // 진행도 바
  Widget buildProgressBar({required int currentStep, int totalSteps = 4}) {
    double progress = currentStep / totalSteps;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: Duration(milliseconds: 300),
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: Color(0xffE4E4E4),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0077FF)),
          ),
        );
      },
    );
  }
}
