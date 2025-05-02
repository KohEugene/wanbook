// 정보 수집 중 화면
import 'package:flutter/material.dart';
import 'dart:async';

import 'collected_screen.dart';

class CollectingScreen extends StatefulWidget {
  final List<String> selectedItems;

  const CollectingScreen({super.key, required this.selectedItems});

  @override
  State<CollectingScreen> createState() => _CollectingScreenState();
}

class _CollectingScreenState extends State<CollectingScreen> {
  late Timer _imageTimer;
  late Timer _navigationTimer;
  bool _showFirstImage = true;

  @override
  void initState() {
    super.initState();

    // 이미지 애니메이션
    _imageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _showFirstImage = !_showFirstImage;
      });
    });

    // 5초 뒤 자동 이동
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      navigateToCollected();
    });
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    _navigationTimer.cancel();
    super.dispose();
  }

  // 다음 페이지로
  void navigateToCollected() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CollectedScreen(
            selectedItems: widget.selectedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('분석 중', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: 16),
              buildProgressBar(currentStep: 2),
              const SizedBox(height: 32),
              buildHeaderText(),
              const SizedBox(height: 60),
              Expanded(child: buildAnimatedImage()),
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
          '책멍이가 정보를 수집 중이에요',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          '잠시만 기다려주세요',
          style: TextStyle(fontSize: 16, color: Color(0xff777777)),
        ),
      ],
    );
  }

  // 이미지 애니메이션
  Widget buildAnimatedImage() {
    return Center(
      child: Image.asset(
        _showFirstImage
            ? 'assets/images/collecting_Chaekmeong_1.png'
            : 'assets/images/collecting_Chaekmeong_2.png',
        width: 200,
        height: 200,
      ),
    );
  }

  // 진행도 바
  Widget buildProgressBar({required int currentStep, int totalSteps = 4}) {
    double progress = currentStep / totalSteps;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 4,
        backgroundColor: Color(0xffD0D0D0),
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xff4A7DFF)),
      ),
    );
  }

}
