import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_model.dart';

class DraftService {
  static const String _draftKeysPrefix = 'quiz_draft_';
  static const String _draftIndicesKey = 'quiz_draft_indices';

  final SharedPreferences _prefs;

  DraftService(this._prefs);

  static Future<DraftService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return DraftService(prefs);
  }

  /// Save a quiz draft locally
  Future<void> saveDraftQuiz(Quiz quiz) async {
    try {
      final draftId =
          quiz.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final quizCopy = Quiz(
        id: draftId,
        title: quiz.title,
        category: quiz.category,
        shareCode: quiz.shareCode,
        questions: quiz.questions,
        creatorId: quiz.creatorId,
      );

      final jsonString = jsonEncode({
        'id': quizCopy.id,
        'title': quizCopy.title,
        'category': quizCopy.category,
        'shareCode': quizCopy.shareCode,
        'creatorId': quizCopy.creatorId,
        'questions': quizCopy.questions
            .map(
              (q) => {
                'text': q.questionText,
                'options': q.options,
                'answerIndex': q.correctAnswerIndex,
              },
            )
            .toList(),
        'savedAt': DateTime.now().toIso8601String(),
        'isSynced': false,
      });

      final key = '$_draftKeysPrefix$draftId';
      await _prefs.setString(key, jsonString);

      // Add to indices
      final indices = _getDraftIndices();
      if (!indices.contains(draftId)) {
        indices.add(draftId);
        await _prefs.setStringList(_draftIndicesKey, indices);
      }
    } catch (e) {
      print('Error saving draft quiz: $e');
      rethrow;
    }
  }

  /// Get all draft quizzes
  Future<List<Quiz>> getAllDrafts() async {
    try {
      final indices = _getDraftIndices();
      final drafts = <Quiz>[];

      for (final id in indices) {
        final key = '$_draftKeysPrefix$id';
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          final data = jsonDecode(jsonString) as Map<String, dynamic>;
          final questions = (data['questions'] as List)
              .map(
                (q) => Question(
                  questionText: q['text'] as String,
                  options: List<String>.from(q['options'] as List),
                  correctAnswerIndex: q['answerIndex'] as int,
                ),
              )
              .toList();

          drafts.add(
            Quiz(
              id: data['id'] as String,
              title: data['title'] as String,
              category: data['category'] as String,
              shareCode: data['shareCode'] as String,
              questions: questions,
              creatorId: data['creatorId'] as String?,
            ),
          );
        }
      }

      return drafts;
    } catch (e) {
      print('Error retrieving drafts: $e');
      return [];
    }
  }

  /// Get a specific draft by ID
  Future<Quiz?> getDraftById(String draftId) async {
    try {
      final key = '$_draftKeysPrefix$draftId';
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final questions = (data['questions'] as List)
          .map(
            (q) => Question(
              questionText: q['text'] as String,
              options: List<String>.from(q['options'] as List),
              correctAnswerIndex: q['answerIndex'] as int,
            ),
          )
          .toList();

      return Quiz(
        id: data['id'] as String,
        title: data['title'] as String,
        category: data['category'] as String,
        shareCode: data['shareCode'] as String,
        questions: questions,
        creatorId: data['creatorId'] as String?,
      );
    } catch (e) {
      print('Error retrieving draft: $e');
      return null;
    }
  }

  /// Delete a draft
  Future<void> deleteDraft(String draftId) async {
    try {
      final key = '$_draftKeysPrefix$draftId';
      await _prefs.remove(key);

      final indices = _getDraftIndices();
      indices.remove(draftId);
      await _prefs.setStringList(_draftIndicesKey, indices);
    } catch (e) {
      print('Error deleting draft: $e');
      rethrow;
    }
  }

  /// Clear all drafts (after successful sync)
  Future<void> clearAllDrafts() async {
    try {
      final indices = _getDraftIndices();
      for (final id in indices) {
        final key = '$_draftKeysPrefix$id';
        await _prefs.remove(key);
      }
      await _prefs.remove(_draftIndicesKey);
    } catch (e) {
      print('Error clearing drafts: $e');
      rethrow;
    }
  }

  /// Get all unsyced drafts
  Future<List<Quiz>> getUnsyncedDrafts() async {
    try {
      final drafts = await getAllDrafts();
      return drafts; // All local drafts are unsyced until uploaded to Firebase
    } catch (e) {
      print('Error retrieving unsynced drafts: $e');
      return [];
    }
  }

  List<String> _getDraftIndices() {
    return _prefs.getStringList(_draftIndicesKey) ?? [];
  }
}
