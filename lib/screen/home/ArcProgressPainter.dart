// 동그라미 원 모양 진행도 바

import 'package:flutter/material.dart';
import 'dart:math';

class ArcProgressPainter extends CustomPainter {
  final double completedRatio; // 전체 중에서 완독한 비율

  ArcProgressPainter({required this.completedRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 60);
    final radius = min(size.width - 60, size.height - 60);

    final backgroundPaint = Paint()
      ..color = const Color(0xffE4E4E4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final progressPaint = Paint()
      ..color = const Color(0xff0077FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final startAngle = -7 * pi / 6;
    final sweepAngle = 4 * pi / 3;

    // 회색: 전체 범위
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // 파란색: 완료된 범위
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * completedRatio,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

