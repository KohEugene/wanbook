import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepProgressBar({
    super.key,
    this.totalSteps = 5,
    this.currentStep = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 15,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 회색 선
          Positioned.fill(
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                totalSteps - 1,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    color: index < currentStep - 1
                        ? Color(0xff4285F4) 
                        : Color(0xffD9D9D9), 
                  ),
                ),
              ),
            ),
          ),

          // 동그라미 + 깃발
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isActive = index < currentStep;
              final isLast = index == totalSteps - 1;

              // 동그라미
              return Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isActive ? Color(0xff4285F4) : Color(0xffD9D9D9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Color(0xff90CAF9) : Color(0xffE0E0E0),
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
