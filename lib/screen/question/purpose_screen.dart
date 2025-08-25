// 독서 목적 (단일 선택)
import 'package:flutter/material.dart';
import 'package:wanbook/screen/question/preknowledge_screen.dart';

class ReadingPurposeScreen extends StatefulWidget {
  final String title;
  const ReadingPurposeScreen({super.key, required this.title});

  @override
  State<ReadingPurposeScreen> createState() => _ReadingPurposeScreenState();
}

class _ReadingPurposeScreenState extends State<ReadingPurposeScreen> {
  String selectedPurpose = ''; 

  final List<String> purposes = [
    '지식 습득',
    '공감 능력 향상',
    '재미와 힐링',
    '치매 예방',
    '어려운 책 정복',
    '독서 습관 형성',
    '자아 성장',
    '어휘력 향상',
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
        title: Text('독서 목적'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              buildProgressBar(currentStep: 0),
              const SizedBox(height: 32),
              buildHeaderText(),
              const SizedBox(height: 76),
              buildPurposeChips(),
              const Spacer(),
              buildBottomButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '주요 독서 목적은 무엇인가요?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          '알맞은 알림 설정을 위하여\n정보가 필요해요!',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildPurposeChips() {
    List<String> leftColumn = [];
    List<String> rightColumn = [];

    for (int i = 0; i < purposes.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(purposes[i]);
      } else {
        rightColumn.add(purposes[i]);
      }
    }

    Widget buildChip(String label) {
      final bool isSelected = label == selectedPurpose;

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () {
            setState(() {
              selectedPurpose = label; 
            });
          },
          child: Container(
            height: 38,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xffCCE4FF) : Color(0xffE4E4E4),
              borderRadius: const BorderRadius.only(
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
            children: leftColumn.map(buildChip).toList(),
          ),
          const SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rightColumn.map(buildChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildBottomButtons() {
    return Row(
      children: [
        // 건너뛰기
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreKnowledgeScreen(
                      title: widget.title,
                      selectedPurpose: selectedPurpose, 
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xffE4E4E4),
                foregroundColor: const Color(0xff777777),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                side: const BorderSide(color: Colors.transparent),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: const Text('건너뛰기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 다음
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                if (selectedPurpose.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xffF8F8F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        '알림',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0077FF),
                        ),
                      ),
                      content: const Text(
                        '독서 목적을 하나 선택해 주세요.',
                        style: TextStyle(fontSize: 16, color: Color(0xff777777)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xff0077FF),
                          ),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreKnowledgeScreen(
                      title: widget.title,
                      selectedPurpose: selectedPurpose, 
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xffCCE4FF),
                foregroundColor: const Color(0xff0077FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                side: const BorderSide(color: Colors.transparent),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text('다음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
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
