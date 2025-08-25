// 사전 지식 (중복 선택)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/provider/user_book_provider.dart';
import 'package:wanbook/screen/question/collecting_screen.dart';
import 'package:wanbook/screen/question/ready_screen.dart';

class PreKnowledgeScreen extends StatefulWidget {
  final String title;
  final String selectedPurpose;

  const PreKnowledgeScreen({
    super.key,
    required this.title,
    required this.selectedPurpose,
  });

  @override
  State<PreKnowledgeScreen> createState() => _PreKnowledgeScreenState();
}

class _PreKnowledgeScreenState extends State<PreKnowledgeScreen> {
  final List<String> preknowledge = [
    '배경 지식',
    '독서 습관 갖는 법',
    '전체적인 플롯',
    '작가 정보',
    '쉽게 읽는 법',
    '줄거리 간단 요약',
    '전문가 서평',
    '책 후기',
  ];

  List<String> selectedPreKnowledgeList = [];

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('사전 지식'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              buildProgressBar(currentStep: 1),
              const SizedBox(height: 32),
              buildHeaderText(),
              const SizedBox(height: 76),
              buildPreKnowledgeChips(),
              const Spacer(),
              buildBottomButtons(context),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          '원하시는 사전 지식이 있으신가요?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          '해당하는 것을 선택하시면\n책멍이가 알려드릴게요!',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 칩 UI
  Widget buildPreKnowledgeChips() {
    final List<String> leftColumn = [];
    final List<String> rightColumn = [];
    for (int i = 0; i < preknowledge.length; i++) {
      (i % 2 == 0 ? leftColumn : rightColumn).add(preknowledge[i]);
    }

    Widget buildChip(String label) {
      final bool isSelected = selectedPreKnowledgeList.contains(label);
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isSelected
                  ? selectedPreKnowledgeList.remove(label)
                  : selectedPreKnowledgeList.add(label);
            });
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xffCCE4FF) : const Color(0xffE4E4E4),
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
                color: isSelected ? const Color(0xff0077FF) : const Color(0xff777777),
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

  Widget buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () async {
                final ubp = Provider.of<UserBookProvider>(context, listen: false);

                await ubp.saveReadingPurposeAndPreknowledge(
                  context,
                  bookId: widget.title,
                  purpose: widget.selectedPurpose, 
                  preknowledge: const [],         
                );

                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReadyScreen(title: widget.title),
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

        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                if (selectedPreKnowledgeList.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
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
                        '하나 이상의 사전 지식을 선택해 주세요.',
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
                    builder: (_) => CollectingScreen(
                      selectedItems: selectedPreKnowledgeList,
                      title: widget.title,
                      purpose: widget.selectedPurpose,
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

  // 진행도 바
  Widget buildProgressBar({required int currentStep, int totalSteps = 4}) {
    final double progress = currentStep / totalSteps;
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
