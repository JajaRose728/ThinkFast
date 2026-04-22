import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class QuizProvider with ChangeNotifier {
  QuizMode _currentMode = QuizMode.normal;
  int _secondsRemaining = 0;
  Timer? _timer;
  int _currentIndex = 0;

  QuizMode get currentMode => _currentMode;
  int get secondsRemaining => _secondsRemaining;

  void startQuiz(QuizMode mode, int initialTime) {
    _currentMode = mode;
    _currentIndex = 0;
    
    if (_currentMode == QuizMode.timed) {
      _secondsRemaining = initialTime;
      _startTimer();
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        // Logic to automatically end quiz or move to next question
      }
    });
  }

  void nextQuestion() {
    _currentIndex++;
    // In Normal mode, we just increment. In Timed mode, maybe reset timer?
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}