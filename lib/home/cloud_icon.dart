import 'package:flutter/material.dart';

class CloudWidget extends StatelessWidget {
  const CloudWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(
        painter: CloudPainter(),
      ),
    );
  }
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFFF8F8F8)
      ..style = PaintingStyle.fill;

    // 구름 배경 (4개의 원 + 말풍선 점)
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.45), 40, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.35), 50, cloudPaint);
    canvas.drawCircle(Offset(size.width * 1.1, size.height * 0.25), 30, cloudPaint);
    canvas.drawCircle(Offset(size.width * 1.3, size.height * 0.6), 45, cloudPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.8), 35, cloudPaint);
    canvas.drawCircle(Offset(size.width * 1.0, size.height * 0.8), 45, cloudPaint);
    
    // 말풍선 느낌의 작은 점들
    canvas.drawCircle(Offset(size.width * 1.4, size.height * 1.3), 15, cloudPaint);
    canvas.drawCircle(Offset(size.width * 1.6, size.height * 1.5), 12, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
