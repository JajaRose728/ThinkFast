import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final remaining = context.watch<QuizProvider>().secondsRemaining;

    // Smooth color transition: green -> orange -> red
    Color timerColor;
    if (remaining > 20) {
      timerColor = AppColors.success;
    } else if (remaining > 10) {
      timerColor = AppColors.warning;
    } else {
      timerColor = AppColors.error;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: timerColor.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: Text(
          '$remaining',
          style: TextStyle(
            color: timerColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
