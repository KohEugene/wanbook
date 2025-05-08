import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String message;

  const SpeechBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: CustomPaint(
            painter: BubblePainter(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              margin: EdgeInsets.only(left: 4, right: 4),
              child: Text(
                message,
                style: TextStyle(
                  color: Color(0xFF0077FF),
                  fontSize: 14,
                ),
                softWrap: true,  // 줄바꿈
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Color(0xFFCCE4FF);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(12),
    );

    canvas.drawRRect(rrect, paint);

    // 말풍선 꼬리 (오른쪽 아래)
    final path = Path();
    path.moveTo(size.width - 20, size.height);
    path.lineTo(size.width - 10, size.height);
    path.lineTo(size.width - 15, size.height + 10);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
