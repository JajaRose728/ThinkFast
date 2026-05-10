import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../utils/constants.dart';

class QuizProvider with ChangeNotifier {
  QuizMode _currentMode = QuizMode.normal;
  int _secondsRemaining = 0;
  Timer? _timer;
  Timer? _autoAdvanceTimer;
  int _currentIndex = 0;
  Quiz? _originalQuiz;
  List<Question> _shuffledQuestions = [];
  int _score = 0;
  bool _hasAnsweredCurrent = false;
  int? _selectedAnswerIndex;

  QuizMode get currentMode => _currentMode;
  int get secondsRemaining => _secondsRemaining;
  Quiz? get quiz => _originalQuiz;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isQuizFinished => _currentIndex >= _shuffledQuestions.length;
  Question? get currentQuestion => !isQuizFinished ? _shuffledQuestions[_currentIndex] : null;
  bool get hasAnsweredCurrent => _hasAnsweredCurrent;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  int get totalQuestions => _shuffledQuestions.length;

  void startQuiz(QuizMode mode, int initialTime, Quiz quiz) {
    _currentMode = mode;
    _originalQuiz = quiz;
    _shuffledQuestions = _shuffleQuestions(quiz.questions);
    _currentIndex = 0;
    _score = 0;
    _hasAnsweredCurrent = false;
    _selectedAnswerIndex = null;
    _autoAdvanceTimer?.cancel();
    
    if (_currentMode == QuizMode.timed) {
      _secondsRemaining = initialTime;
      _startTimer();
    }
    notifyListeners();
  }

  List<Question> _shuffleQuestions(List<Question> original) {
    return original.map((q) {
      final indices = List<int>.generate(q.options.length, (i) => i);
      indices.shuffle(Random());
      final shuffledOptions = indices.map((i) => q.options[i]).toList();
      final newCorrectIndex = indices.indexOf(q.correctAnswerIndex);
      return Question(
        questionText: q.questionText,
        options: shuffledOptions,
        correctAnswerIndex: newCorrectIndex,
      );
    }).toList();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        if (!_hasAnsweredCurrent && !isQuizFinished) {
          answerQuestion(-1);
        }
      }
    });
  }

  void answerQuestion(int selectedIndex) {
    if (_hasAnsweredCurrent || isQuizFinished) return;
    
    _selectedAnswerIndex = selectedIndex;
    _hasAnsweredCurrent = true;
    
    if (currentQuestion != null && selectedIndex == currentQuestion!.correctAnswerIndex) {
      _score++;
    }
    
    _timer?.cancel();
    notifyListeners();
    
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(milliseconds: 1500), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    if (isQuizFinished) return;
    
    _autoAdvanceTimer?.cancel();
    _currentIndex++;
    _hasAnsweredCurrent = false;
    _selectedAnswerIndex = null;
    
    if (_currentMode == QuizMode.timed && !isQuizFinished) {
      _secondsRemaining = 30;
      _startTimer();
    }
    
    notifyListeners();
  }

  void resetQuiz() {
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    _originalQuiz = null;
    _shuffledQuestions = [];
    _currentIndex = 0;
    _score = 0;
    _hasAnsweredCurrent = false;
    _selectedAnswerIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }
}

