// 사전지식 분석 결과 화면 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanbook/screen/question/ready_screen.dart';
import 'package:wanbook/provider/user_book_provider.dart';

class CollectedScreen extends StatefulWidget {
  final List<String> selectedItems; 
  final String title;              
  final String purpose;           
  final Map<String, String> preloadedAnswers; 

  const CollectedScreen({
    super.key,
    required this.selectedItems,
    required this.title,
    required this.purpose,
    required this.preloadedAnswers,
  });

  @override
  State<CollectedScreen> createState() => _CollectedScreenState();
}

class _CollectedScreenState extends State<CollectedScreen> {
  Set<String> expandedCards = {};

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('분석 완료'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              buildProgressBar(currentStep: 3),
              const SizedBox(height: 32),
              buildHeaderText(),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: widget.selectedItems
                      .map((title) => buildInfoCard(title))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),
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
      children: const [
        Text(
          '책멍이가 정보 수집을 완료했어요!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          '해당 정보를 클릭하시면\n더 자세한 내용을 볼 수 있어요',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildInfoCard(String title) {
    bool isExpanded = expandedCards.contains(title);

    final String answerText =
        widget.preloadedAnswers[title] ?? '해당 주제에 대한 정보를 준비하지 못했습니다.';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      expandedCards.remove(title);
                    } else {
                      expandedCards.add(title);
                    }
                  });
                },
                child: isExpanded
                    ? Row(
                        children: const [
                          Text(
                            '접기',
                            style: TextStyle(
                                color: Color(0xff777777),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xff777777),
                            size: 14,
                          )
                        ],
                      )
                    : Row(
                        children: const [
                          Text(
                            '더보기',
                            style: TextStyle(
                                color: Color(0xff777777),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
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
          const SizedBox(height: 12),
          Text(
            answerText,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
            maxLines: isExpanded ? null : 5,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildBottomButtons() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () async {
          final userBookProvider =
              Provider.of<UserBookProvider>(context, listen: false);

          await userBookProvider.saveReadingPurposeAndPreknowledge(
            context,
            bookId: widget.title,     
            purpose: widget.purpose,    
            preknowledge: widget.selectedItems,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadyScreen(title: widget.title),
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
