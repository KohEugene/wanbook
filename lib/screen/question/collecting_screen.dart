// 선택한 사전 지식 있을 시
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'collected_screen.dart';

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

    // 이미지 애니메이션
    _imageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _showFirstImage = !_showFirstImage;
      });
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
      for (final topic in widget.selectedItems) {
        final answer = await _callGptForTopic(topic);
        _answers[topic] = answer;
      }

      if (!mounted) return;
      setState(() {
        _isRequesting = false;
      });
      navigateToCollected();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRequesting = false;
        _errorMsg = '정보를 수집하는 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  Future<String> _callGptForTopic(String topic) async {
    const apiKey = '';
    const endpoint = "https://api.openai.com/v1/chat/completions";

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final systemForBook = """
    당신은 독서 도우미 AI입니다.
    현재 사용자가 읽는 책 제목은 "${widget.title}" 입니다.
    목적은 "${widget.purpose}" 입니다.
    지금 사용자가 궁금해하는 사전 지식 주제는 "$topic" 입니다.
    - "${widget.title}"을 중심으로, "$topic"과 관련된 배경지식/핵심정보를 알려주세요.
    - 한국어로 친절하게 답하세요.
    """;

    final body = json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "system", "content": systemForBook},
        {"role": "user", "content": "이 책과 관련된 '$topic' 정보를 알려줘."}
      ],
      "temperature": 0.7,
    });

    final response = await http.post(Uri.parse(endpoint), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = (data['choices'][0]['message']['content'] as String?)?.trim() ?? "";
      return reply.isEmpty ? "해당 주제에 대한 정보를 준비하지 못했습니다." : reply;
    } else {
      return "'$topic'에 대한 정보를 불러오지 못했습니다.";
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
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff777777),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '잠시만 기다려주세요',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff777777),
          ),
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
    double progress = currentStep / totalSteps;

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
