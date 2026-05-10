import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final question = quizProvider.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(quizProvider.quiz?.title ?? 'Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            quizProvider.resetQuiz();
            Navigator.pop(context);
          },
        ),
      ),
      body: quizProvider.isQuizFinished
          ? _buildResults(context, quizProvider)
          : question == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (quizProvider.currentMode == QuizMode.timed)
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: quizProvider.secondsRemaining / 30,
                                backgroundColor: AppColors.divider,
                                color: quizProvider.secondsRemaining < 10 ? AppColors.error : AppColors.success,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${quizProvider.secondsRemaining}s',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: quizProvider.secondsRemaining < 10 ? AppColors.error : AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Question ${quizProvider.currentIndex + 1} of ${quizProvider.totalQuestions}',
                          style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question.questionText,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(question.options.length, (index) {
                        final isSelected = quizProvider.selectedAnswerIndex == index;
                        final isCorrect = index == question.correctAnswerIndex;
                        final hasAnswered = quizProvider.hasAnsweredCurrent;
                        final optionColor = optionColors[index % optionColors.length];

                        Color bgColor = AppColors.surface;
                        Color borderColor = AppColors.divider;

                        if (hasAnswered) {
                          if (isCorrect) {
                            bgColor = AppColors.success.withOpacity(0.1);
                            borderColor = AppColors.success;
                          } else if (isSelected && !isCorrect) {
                            bgColor = AppColors.error.withOpacity(0.1);
                            borderColor = AppColors.error;
                          }
                        } else if (isSelected) {
                          bgColor = optionColor.withOpacity(0.1);
                          borderColor = optionColor;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: hasAnswered ? null : () => quizProvider.answerQuestion(index),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor, width: hasAnswered && (isCorrect || isSelected) ? 2 : 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: hasAnswered
                                          ? (isCorrect ? AppColors.success : (isSelected ? AppColors.error : optionColor.withOpacity(0.1)))
                                          : optionColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: hasAnswered
                                              ? (isCorrect || isSelected ? Colors.white : optionColor)
                                              : optionColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: hasAnswered && !isCorrect && isSelected ? AppColors.error : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (hasAnswered)
                                    Icon(
                                      isCorrect ? Icons.check_circle : (isSelected ? Icons.cancel : null),
                                      color: isCorrect ? AppColors.success : AppColors.error,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const Spacer(),
                      if (quizProvider.hasAnsweredCurrent)
                        ElevatedButton(
                          onPressed: () => quizProvider.nextQuestion(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            quizProvider.currentIndex < quizProvider.totalQuestions - 1 ? 'Next Question' : 'See Results',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildResults(BuildContext context, QuizProvider quizProvider) {
    if (quizProvider.totalQuestions == 0) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No questions in this quiz!',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final percentage = (quizProvider.score / quizProvider.totalQuestions).clamp(0.0, 1.0);
    final resultColor = percentage >= 0.7 ? AppColors.success : (percentage >= 0.4 ? AppColors.warning : AppColors.error);
    final resultIcon = percentage >= 0.7 ? Icons.emoji_events : (percentage >= 0.4 ? Icons.thumb_up : Icons.sentiment_dissatisfied);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(resultIcon, size: 56, color: resultColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Quiz Complete!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            percentage >= 0.7 ? 'Great job!' : (percentage >= 0.4 ? 'Good effort!' : 'Keep practicing!'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resultColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '${quizProvider.score} / ${quizProvider.totalQuestions}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: resultColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(percentage * 100).toInt()}% Correct',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: resultColor.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              quizProvider.resetQuiz();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

