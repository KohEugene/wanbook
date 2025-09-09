// 분석 그래프 위젯들 모음
import 'dart:math' as math;
import 'package:flutter/material.dart';

// 독서 시간대 (막대 그래프)
class HourBars extends StatelessWidget {
  const HourBars({
    super.key,
    required this.values,
    this.barMax = 130,
    this.barWidth = 18,
    this.gap = 8,
  });

  final List<double> values; 
  final double barMax;     
  final double barWidth;   
  final double gap;         

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);

    final contentWidth = values.length * (barWidth + gap);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: contentWidth),
        child: Column(
          children: [
            SizedBox(
              height: barMax,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < values.length; i++) ...[
                    Container(
                      width: barWidth,
                      height: (values[i] / maxV) * barMax,
                      decoration: BoxDecoration(
                        color: const Color(0xff0077FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: gap),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Row(
                children: [
                  for (int i = 0; i < values.length; i++) ...[
                    SizedBox(
                      width: barWidth,
                      child: Text(
                        '$i',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xff777777),
                        ),
                      ),
                    ),
                    SizedBox(width: gap),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 진핼률 정체 구간 (꺾은선 그래프)
class DwellLineChart extends StatelessWidget {
  const DwellLineChart({
    super.key,
    required this.dwell,
    this.height = 160,
    this.step = 6,
    this.showXAxisLabels = true,
    this.labelInterval = 10, 
    this.labelBuilder,    
    this.axisLabelStyle =
        const TextStyle(fontSize: 11, color: Color(0xff777777)),
  });

  final List<int> dwell;            
  final double height;         
  final double step;                 
  final bool showXAxisLabels;        
  final int labelInterval;            
  final String Function(int value)? labelBuilder; 
  final TextStyle axisLabelStyle;     

  @override
  Widget build(BuildContext context) {
    final maxY = (dwell.isEmpty ? 1 : dwell.reduce((a, b) => a > b ? a : b))
        .clamp(1, 999999);
    const left = 8.0;
    final width = left + step * 100 + 10.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: height + 28,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(width, height + 28),
              painter: _LinePainterDense(
                dwell: dwell,
                maxY: maxY.toDouble(),
                step: step,
                leftPadding: left,
                tickInterval: labelInterval,
              ),
            ),
            if (showXAxisLabels)
              Positioned(
                left: 0,
                bottom: 0,
                child: CustomPaint(
                  size: Size(width, 28),
                  painter: _XAxisLabelsPainter(
                    leftPadding: left,
                    step: step,
                    labelInterval: labelInterval,
                    labelBuilder: labelBuilder,
                    style: axisLabelStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 꺾은선 그래프 가이드라인+선 그리기 (경로 계산)
class _LinePainterDense extends CustomPainter {
  _LinePainterDense({
    required this.dwell,
    required this.maxY,
    required this.step,
    required this.leftPadding,
    required this.tickInterval,
  });

  final List<int> dwell;
  final double maxY;
  final double step;
  final double leftPadding;
  final int tickInterval;

  @override
  void paint(Canvas canvas, Size size) {
    final top = 8.0;
    final bottom = 32.0;
    final h = size.height - top - bottom;

    final guide = Paint()..color = const Color(0x11000000);
    for (int v = 0; v <= 100; v += tickInterval) {
      final x = leftPadding + step * v;
      canvas.drawLine(Offset(x, top), Offset(x, top + h), guide);
    }

    final p = Path();
    double lastY = top + h; 
    for (int i = 0; i < dwell.length; i++) {
      final x = leftPadding + i * step;
      final norm = dwell[i] / maxY;
      final y = top + h * (1 - norm);
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
      if (i == dwell.length - 1) lastY = y;
    }

    final endX = leftPadding + step * 100;
    final lastDataIndex = dwell.isEmpty ? 0 : dwell.length - 1;
    final lastDataX = leftPadding + step * lastDataIndex;
    if (lastDataX < endX) {
      p.lineTo(endX, lastY);
    }

    final stroke = Paint()
      ..color = const Color(0xff0077FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fill = Paint()
      ..color = const Color(0xffCCE4FF)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(p)
      ..lineTo(endX, top + h)
      ..lineTo(leftPadding, top + h)
      ..close();

    canvas.drawPath(fillPath, fill);
    canvas.drawPath(p, stroke);
  }

  @override
  bool shouldRepaint(covariant _LinePainterDense old) =>
      old.dwell != dwell ||
      old.step != step ||
      old.maxY != maxY ||
      old.leftPadding != leftPadding ||
      old.tickInterval != tickInterval;
}

// 꺾은선 그래프 x축 라벨 가이드라인에 맞춰 정렬
class _XAxisLabelsPainter extends CustomPainter {
  _XAxisLabelsPainter({
    required this.leftPadding,
    required this.step,
    required this.labelInterval,
    required this.style,
    this.labelBuilder,
  });

  final double leftPadding;
  final double step;
  final int labelInterval;
  final TextStyle style;
  final String Function(int value)? labelBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    for (int v = 0; v <= 100; v += labelInterval) {
      final x = leftPadding + step * v;

      final text = labelBuilder?.call(v) ?? '$v';
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final dx = x - tp.width / 2;
      final dy = size.height / 2 - tp.height / 2; 
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant _XAxisLabelsPainter old) =>
      old.leftPadding != leftPadding ||
      old.step != step ||
      old.labelInterval != labelInterval ||
      old.style != style ||
      old.labelBuilder != labelBuilder;
}

// 오각형 레이더
class HabitRadarChart extends StatelessWidget {
  const HabitRadarChart({
    super.key,
    required this.scores, 
    this.labelPush = 8,  
  });

  final List<double> scores;
  final double labelPush;

  static const labels = ['꾸준', '집중', '안정', '재독', '리듬'];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: LayoutBuilder(
        builder: (context, c) {
          final center = Offset(c.maxWidth / 2, c.maxHeight / 2 + 6);
          final radius = math.min(c.maxWidth, c.maxHeight) * 0.32;

          final vertices = List<Offset>.generate(5, (i) {
            final th = -math.pi / 2 + 2 * math.pi * i / 5;
            return center + Offset(math.cos(th), math.sin(th)) * radius;
          });

          final placed = vertices.map((v) {
            if (labelPush == 0) return v;
            final dir = (v - center);
            final len = dir.distance == 0 ? 1 : dir.distance;
            final unit = Offset(dir.dx / len, dir.dy / len);
            return v + unit * labelPush;
          }).toList();

          return Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _RadarPainter(scores: scores),
              ),
              for (int i = 0; i < 5; i++)
                CustomSingleChildLayout(
                  delegate: _VertexPositionDelegate(target: placed[i]),
                  child: _LabelChip(
                    text: '${labels[i]} ${scores[i].round()}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// 라벨 상자 꼭짓점 위치 계산 후 위치시키기
class _VertexPositionDelegate extends SingleChildLayoutDelegate {
  _VertexPositionDelegate({required this.target});
  final Offset target;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(target.dx - childSize.width / 2, target.dy - childSize.height / 2);
  }

  @override
  bool shouldRelayout(covariant _VertexPositionDelegate oldDelegate) =>
      oldDelegate.target != target;
}

// 회색 라벨 칩
class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// 오각형 레이더 그리기 (좌표 계산)
class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.scores});
  final List<double> scores;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 5;
    if (scores.length < n) return;

    final c = Offset(size.width / 2, size.height / 2 + 6);
    final radius = size.shortestSide * 0.32;

    // 스타일
    final grid = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.stroke;
    final axis = Paint()
      ..color = const Color(0x33000000)
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = const Color(0xffCCE4FF) 
      ..style = PaintingStyle.fill;
    final line = Paint()
      ..color = const Color(0xff0077FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final r in [radius * 0.34, radius * 0.67, radius]) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final th = -math.pi / 2 + 2 * math.pi * i / n;
        final pt = c + Offset(math.cos(th), math.sin(th)) * r;
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, grid);
    }

    for (int i = 0; i < n; i++) {
      final th = -math.pi / 2 + 2 * math.pi * i / n;
      canvas.drawLine(c, c + Offset(math.cos(th), math.sin(th)) * radius, axis);
    }

    final p = Path();
    for (int i = 0; i < n; i++) {
      final th = -math.pi / 2 + 2 * math.pi * i / n;
      final r = radius * (scores[i] / 100.0);
      final pt = c + Offset(math.cos(th), math.sin(th)) * r;
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    p.close();
    canvas.drawPath(p, fill);
    canvas.drawPath(p, line);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => old.scores != scores;
}
