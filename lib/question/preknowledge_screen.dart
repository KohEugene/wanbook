import 'package:flutter/material.dart';
import 'package:wanbook/question/collecting_screen.dart';
import 'package:wanbook/question/collected_screen.dart';
import 'package:wanbook/question/ready_screen.dart';

class PreKnowledgeScreen extends StatefulWidget {
  final String title;
  const PreKnowledgeScreen({super.key, required this.title});

  @override
  State<PreKnowledgeScreen> createState() => _PreKnowledgeScreenState();
}

class _PreKnowledgeScreenState extends State<PreKnowledgeScreen> {
  String selectedPreKnowledge = '배경 지식';

  final List<String> preknowledge = [
    '배경 지식',
    '독서 습관 갖는 법',
    '전체적인 플룻',
    '작가 정보',
    '쉽게 읽는 법',
    '줄거리 간단 요약',
    '전문가 서평',
    '책 후기',
  ];

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('사전 지식'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              buildProgressBar(currentStep: 1), // 진행도 표시 
              const SizedBox(height: 32),
              buildHeaderText(),
              const SizedBox(height: 76),
              buildPreKnowledgeChips(),
              const Spacer(),
              buildBottomButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // 위에 질문 목록
  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 가운데 정렬
      children: [
        Text(
          '원하시는 사전 지식이 있으신가요?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: TextAlign.center, // 줄 바꿈 시에도 중앙 정렬
        ),
        const SizedBox(height: 6),
        Text(
          '해당하는 것을 선택하시면\n책멍이가 알려드릴게요!',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 사전지식 물어보는 목록
  List<String> selectedPreKnowledgeList = []; // 선택한 거 저장하는 리스트트

  Widget buildPreKnowledgeChips() {
    List<String> leftColumn = [];
    List<String> rightColumn = [];

    for (int i = 0; i < preknowledge.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(preknowledge[i]);
      } else {
        rightColumn.add(preknowledge[i]);
      }
    }

    Widget buildChip(String label) {
      final bool isSelected = selectedPreKnowledgeList.contains(label);

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedPreKnowledgeList.remove(label);
              } else {
                selectedPreKnowledgeList.add(label);
              }
            });
          },
          child: Container(
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xffCCE4FF) : Color(0xffE4E4E4),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(2),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Color(0xff0077FF) : Color(0xff777777),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: leftColumn.map((e) => buildChip(e)).toList(),
          ),
          const SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightColumn.map((e) => buildChip(e)).toList(),
          ),
        ],
      ),
    );
  }

  // 하단 버튼 두개
  Widget buildBottomButtons() {
    return Row(
      children: [
        // 건너뛰기 버튼
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadyScreen(title: widget.title),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xffE4E4E4),
                foregroundColor: Color(0xff777777),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                side: BorderSide(color: Colors.transparent),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text('건너뛰기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 다음 버튼
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
                onPressed: () {
                if (selectedPreKnowledgeList.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Color(0xffF8F8F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          '알림',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0077FF),
                          ),
                        ),
                        content: Text(
                          '하나 이상의 사전 지식을 선택해 주세요.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff777777),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Color(0xff0077FF),
                            ),
                            child: Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectingScreen(
                        selectedItems: selectedPreKnowledgeList, title: widget.title
                      ),
                    ),
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xffCCE4FF),
                foregroundColor: Color(0xff0077FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                side: BorderSide(color: Colors.transparent),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
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