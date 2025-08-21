import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../provider/badge_provider.dart';

class AchievementScreen extends StatefulWidget {
  final List<BadgeItem> badges;

  const AchievementScreen({Key? key, required this.badges}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  late AnimationController _swingController;
  late Animation<double> _swingAnim;

  @override
  void initState() {
    super.initState();

    _swingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // 총 애니메이션 시간
    );

    // 좌우로 점점 작게 흔들고 멈추기
    _swingAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: -0.35), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.35, end: 0.25), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.15), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.08, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _swingController,
      curve: Curves.easeOut,
    ));

    _swingController.forward(); // 시작하자마자 애니메이션 실행
  }

  @override
  void dispose() {
    _swingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/confetti.json',
                repeat: false,
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 20),

              Column(
                children: widget.badges.map((b) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _swingAnim,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _swingAnim.value * math.pi,
                              child: child,
                            );
                          },
                          child: SvgPicture.asset(
                            b.asset,
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          b.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "조건: ${b.threshold}권 이상",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff0077FF),
                  backgroundColor: const Color(0xffCCE4FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  side: const BorderSide(color: Colors.transparent),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "확인",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
