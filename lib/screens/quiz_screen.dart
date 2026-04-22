import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(quizProvider.currentMode == QuizMode.timed 
          ? "Timed Challenge" 
          : "Normal Practice"),
      ),
      body: Column(
        children: [
          // Only show the timer if we are in Timed Mode
          if (quizProvider.currentMode == QuizMode.timed)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: quizProvider.secondsRemaining / 30, // assuming 30s limit
                backgroundColor: Colors.grey[300],
                color: quizProvider.secondsRemaining < 10 ? Colors.red : Colors.green,
              ),
            ),
          
          const Expanded(
            child: Center(child: Text("Question Content Here")),
          ),
          
          ElevatedButton(
            onPressed: () => quizProvider.nextQuestion(),
            child: const Text("Next Question"),
          ),
        ],
      ),
    );
  }
}