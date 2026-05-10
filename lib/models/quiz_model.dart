class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class Quiz {
  final String? id;
  final String title;
  final String category;
  final List<Question> questions;
  final String shareCode;
  final String? creatorId;
  final List<String>? sharedWith;

  Quiz({
    this.id,
    required this.title,
    required this.category,
    required this.questions,
    required this.shareCode,
    this.creatorId,
    this.sharedWith,
  });

  factory Quiz.fromMap(String docId, Map<String, dynamic> map) {
    return Quiz(
      id: docId,
      title: map['title'] ?? 'Untitled',
      category: map['category'] ?? 'General',
      shareCode: map['shareCode'] ?? '',
      creatorId: map['creatorId'] ?? '',
      sharedWith: map['sharedWith'] != null 
          ? List<String>.from(map['sharedWith']) 
          : [], 
      questions: (map['questions'] as List? ?? []).map((q) => Question(
        questionText: q['text'] ?? '',
        options: List<String>.from(q['options'] ?? []),
        correctAnswerIndex: q['answerIndex'] ?? 0,
      )).toList(),
    );
  }
}

