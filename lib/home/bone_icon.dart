import 'package:flutter/material.dart';

class SimpleBonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = Color(0xff0077FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // 양 끝 원
    canvas.drawCircle(Offset(63, 40), 14, bonePaint);
    canvas.drawCircle(Offset(115, 0), 14, bonePaint);

    // 직선 연결
    canvas.drawLine(Offset(65, 40), Offset(115, 0), bonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SimpleBoneIcon extends StatelessWidget {
  const SimpleBoneIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(140, 140),
      painter: SimpleBonePainter(),
    );
  }
}
