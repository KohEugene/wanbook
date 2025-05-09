import 'package:flutter/material.dart';
import 'dart:async';

class PngFrameAnimation extends StatefulWidget {
  final String basePath; // ex: 'assets/images/hint_chaekmeong/frame_'
  final int frameCount;  // ex: 30
  final Duration interval;
  final double width;
  final double height;

  const PngFrameAnimation({
    required this.basePath,
    required this.frameCount,
    required this.interval,
    this.width = 100,
    this.height = 100,
    super.key,
  });

  @override
  State<PngFrameAnimation> createState() => _PngFrameAnimationState();
}

class _PngFrameAnimationState extends State<PngFrameAnimation> {
  int _currentFrame = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(widget.interval, (timer) {
      if (_currentFrame < widget.frameCount - 1) {
        setState(() {
          _currentFrame++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final path = '${widget.basePath}${_currentFrame + 1}.png';
    return Image.asset(
      path,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true, // 프레임 전환 시 깜빡임 방지
    );
  }
}
