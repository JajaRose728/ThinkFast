import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key}); // Optimization: Use const [cite: 175]

  @override
  Widget build(BuildContext context) {
    final remaining = context.watch<QuizProvider>().secondsRemaining;

    return CircleAvatar(
      radius: 30,
      backgroundColor: remaining < 10 ? Colors.red : Colors.blue,
      child: Text(
        '$remaining',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}