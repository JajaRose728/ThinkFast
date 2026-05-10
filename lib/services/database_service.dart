import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SAVE: Send a quiz to Firestore
  Future<void> uploadQuiz(Quiz quiz, String userId) async {
    try {
      final docRef = await _db.collection('quizzes').add({
        'title': quiz.title,
        'category': quiz.category,
        'shareCode': quiz.shareCode,
        'creatorId': userId,
        'sharedWith': [userId], // Creator is automatically included
        'questions': quiz.questions.map((q) => {
          'text': q.questionText,
          'options': q.options,
          'answerIndex': q.correctAnswerIndex,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Create a public lookup entry so others can import by share code
      await _db.collection('shareCodes').doc(quiz.shareCode).set({
        'quizId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error uploading: $e");
      throw Exception("Failed to upload quiz: $e");
    }
  }

  // UPDATE: Update an existing quiz (only creator should call this)
  Future<void> updateQuiz(Quiz quiz) async {
    if (quiz.id == null) throw Exception("Quiz ID is required for update");
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final quizDoc = await _db.collection('quizzes').doc(quiz.id).get();
      if (!quizDoc.exists) throw Exception("Quiz not found");
      if (quizDoc.data()?['creatorId'] != user.uid) {
        throw Exception("Only the quiz creator can update this quiz");
      }

      await _db.collection('quizzes').doc(quiz.id).update({
        'title': quiz.title,
        'category': quiz.category,
        'questions': quiz.questions.map((q) => {
          'text': q.questionText,
          'options': q.options,
          'answerIndex': q.correctAnswerIndex,
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating: $e");
      throw Exception("Failed to update quiz: $e");
    }
  }

  // DELETE: Delete a quiz and its share code (only creator should call this)
  Future<void> deleteQuiz(String quizId, String shareCode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated");

      // First verify the user is the creator before attempting deletion
      final quizDoc = await _db.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) throw Exception("Quiz not found");
      if (quizDoc.data()?['creatorId'] != user.uid) {
        throw Exception("Only the quiz creator can delete this quiz");
      }

      final codeToDelete = shareCode.trim().isNotEmpty
          ? shareCode.trim()
          : (quizDoc.data()?['shareCode'] ?? '').toString().trim();

      // Delete share code first (in case share code deletion fails, quiz remains)
      if (codeToDelete.isNotEmpty) {
        try {
          await _db.collection('shareCodes').doc(codeToDelete).delete();
        } catch (e) {
          print("Warning: Could not delete share code: $e");
          // Continue with quiz deletion even if share code fails
        }
      }

      // Then delete the quiz
      await _db.collection('quizzes').doc(quizId).delete();
    } catch (e) {
      print("Error deleting: $e");
      throw Exception("Failed to delete quiz: $e");
    }
  }

  // FETCH: Get quizzes where user is creator OR has imported via code
  Stream<List<Quiz>> getQuizzesForUser(String category) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    // Query for quizzes where user is creator OR is in sharedWith.
    // This is safe with the updated rules that allow read for either condition.
    Query query = _db.collection('quizzes').where(
      Filter.or(
        Filter('creatorId', isEqualTo: user.uid),
        Filter('sharedWith', arrayContains: user.uid),
      ),
    );

    return query.snapshots().map((snapshot) {
      var quizzes = snapshot.docs.map((doc) {
        return Quiz.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      // Filter by category client-side to avoid composite index issues
      if (category != 'All') {
        quizzes = quizzes.where((quiz) => quiz.category == category).toList();
      }

      return quizzes;
    });
  }
}
