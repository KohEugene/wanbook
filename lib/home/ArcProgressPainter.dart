// 동그라미 원 모양 진행도 바

import 'package:flutter/material.dart';
import 'dart:math';

class ArcProgressPainter extends CustomPainter {
  final double progress;
  ArcProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 60);
    final radius = min(size.width - 60, size.height - 60);

    // 비진행? 원
    final backgroundPaint = Paint()
      ..color = Color(0xffE4E4E4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // 진행 원
    final progressPaint = Paint()
      ..color = Color(0xFF0077FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // 230도 호
    final startAngle = -7 * pi / 6; // 시작점
    final sweepAngle = 4 * pi / 3 * progress; // 진행률

    // 배경 전체 호
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      4 * pi / 3,
      false,
      backgroundPaint,
    );

    // 실제 진행률 호
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
