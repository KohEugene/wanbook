// 수집 중 화면
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'collected_screen.dart';
import '../../shared/openai_shared.dart'; 

class CollectingScreen extends StatefulWidget {
  final List<String> selectedItems; 
  final String title;
  final String purpose;      

  const CollectingScreen({
    super.key,
    required this.selectedItems,
    required this.title,
    required this.purpose,
  });

  @override
  State<CollectingScreen> createState() => _CollectingScreenState();
}

class _CollectingScreenState extends State<CollectingScreen> {
  late Timer _imageTimer;
  bool _showFirstImage = true;
  final Map<String, String> _answers = {};
  bool _isRequesting = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _imageTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _showFirstImage = !_showFirstImage);
    });
    _requestAllTopics();
  }

  @override
  void dispose() {
    _imageTimer.cancel();
    super.dispose();
  }

  Future<void> _requestAllTopics() async {
    if (_isRequesting) return;
    setState(() {
      _isRequesting = true;
      _errorMsg = null;
      _answers.clear();
    });

    try {
      // 병렬 호출로 수집 속도 개선
      final futures = widget.selectedItems.map((topic) async {
        final answer = await OpenAIShared.fetchTopicSummary(
          bookTitle: widget.title,
          purpose: widget.purpose,
          topic: topic,
        );
        return MapEntry(topic, answer);
      }).toList();

      final results = await Future.wait(futures);
      for (final e in results) {
        _answers[e.key] = e.value;
      }

      if (!mounted) return;
      setState(() => _isRequesting = false);
      navigateToCollected();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRequesting = false;
        _errorMsg = '정보를 수집하는 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  void navigateToCollected() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CollectedScreen(
          selectedItems: widget.selectedItems,
          title: widget.title,
          purpose: widget.purpose,
          preloadedAnswers: Map<String, String>.from(_answers),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('분석 중'),
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
              const SizedBox(height: 12),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      children: [
        const Text(
          '책멍이가 정보를 수집 중이에요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(
          '${_answers.length} / ${widget.selectedItems.length} 수집 완료',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
        ),
        const SizedBox(height: 2),
        const Text(
          '잠시만 기다려주세요',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
        ),
      ],
    );
  }

  Widget buildAnimatedImage() {
    return Center(
      child: SvgPicture.asset(
        _showFirstImage
            ? 'assets/images/collecting_Chaekmeong_1.svg'
            : 'assets/images/collecting_Chaekmeong_2.svg',
        width: 200,
        height: 200,
      ),
    );
  }

  Widget buildProgressBar({required int currentStep, int totalSteps = 4}) {
    final progress = currentStep / totalSteps;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: const Color(0xffE4E4E4),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff0077FF)),
          ),
        );
      },
    );
  }
}
