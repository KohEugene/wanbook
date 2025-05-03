import 'package:flutter/material.dart';
import 'package:wanbook/question/ready_screen.dart';

class CollectedScreen extends StatefulWidget {
  final List<String> selectedItems;
  final String title;

  const CollectedScreen({super.key, required this.selectedItems, required this.title});

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
          icon: Icon(Icons.chevron_left_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('분석 완료'),
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

  // 위에 질문 목록
  Widget buildHeaderText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // 텍스트 가운데 정렬
      children: [
        Text(
          '책멍이가 정보 수집을 완료했어요!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
          textAlign: TextAlign.center, // 줄 바꿈 시에도 중앙 정렬
        ),
        const SizedBox(height: 6),
        Text(
          '해당 정보를 클릭하시면\n더 자세한 내용을 볼 수 있어요',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xff777777)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 카드 위젯 생성 함수
   Widget buildInfoCard(String title) {
    bool isExpanded = expandedCards.contains(title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xffF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 더보기
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black
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
                    children: [
                      Text('접기', style: TextStyle(
                        color: Color(0xff777777),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                      ),
                      Icon(Icons.chevron_left_rounded,
                        color: Color(0xff777777),
                        size: 14,
                      )
                    ],
                  )
                : Row(
                    children: [
                      Text('더보기', style: TextStyle(
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
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lorem ipsum dolor sit amet consectetur. Venenatis iaculis senectus vulputate id eget pretium. '
            'Vivamus dignissim lectus sed pellentesque tellus. Lorem ipsum dolor sit amet consectetur. ''Lorem ipsum dolor sit amet consectetur. Venenatis iaculis senectus vulputate id eget pretium. '
            'Vivamus dignissim lectus sed pellentesque tellus. Lorem ipsum dolor sit amet consectetur. ''Lorem ipsum dolor sit amet consectetur. Venenatis iaculis senectus vulputate id eget pretium. '
            'Vivamus dignissim lectus sed pellentesque tellus. Lorem ipsum dolor sit amet consectetur. ''Lorem ipsum dolor sit amet consectetur. Venenatis iaculis senectus vulputate id eget pretium. '
            'Vivamus dignissim lectus sed pellentesque tellus. Lorem ipsum dolor sit amet consectetur. ''Lorem ipsum dolor sit amet consectetur. Venenatis iaculis senectus vulputate id eget pretium. '
            'Vivamus dignissim lectus sed pellentesque tellus. Lorem ipsum dolor sit amet consectetur. '
            'Venenatis iaculis senectus vulputate id eget pretium. Vivamus dignissim lectus sed pellentesque tellus.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff777777)),
            maxLines: isExpanded ? null : 5,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 하단 버튼 한개
  Widget buildBottomButtons() {
  return SizedBox(
    width: double.infinity,
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
      child: Text('다음', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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