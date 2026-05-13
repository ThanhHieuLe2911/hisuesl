import 'dart:convert';

enum QuestionType {
  multipleChoice,
  arrange,
  listening,
  typing,
}

class QuestionModel {
  final String id;
  final int unitId;
  final QuestionType type;
  final String questionText;
  final dynamic correctAnswer;
  final List<String>? options;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.unitId,
    required this.type,
    required this.questionText,
    required this.correctAnswer,
    this.options,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> options = [];
    if (json['options'] != null) {
      if (json['options'] is List) {
        options = (json['options'] as List).map((e) => e.toString()).toList();
      } else if (json['options'] is String && (json['options'] as String).isNotEmpty) {
        try {
          final parsed = jsonDecode(json['options'] as String);
          if (parsed is List) options = parsed.map((e) => e.toString()).toList();
        } catch (_) {}
      }
    }

    dynamic correctAnswer = json['correct_answer'];
    if (correctAnswer is String && correctAnswer.startsWith('[')) {
      try {
        correctAnswer = List<String>.from(jsonDecode(correctAnswer));
      } catch (_) {}
    }

    return QuestionModel(
      id: json['id']?.toString() ?? '',
      unitId: json['unit_id'] as int? ?? 0,
      type: _parseType(json['type'] as String?),
      questionText: json['question_text'] as String? ?? '',
      correctAnswer: correctAnswer,
      options: options.isEmpty ? null : options,
    );
  }

  static QuestionType _parseType(String? type) {
    switch (type) {
      case 'multipleChoice':
        return QuestionType.multipleChoice;
      case 'typing':
        return QuestionType.typing;
      case 'listening':
        return QuestionType.listening;
      case 'arrange':
        return QuestionType.arrange;
      default:
        return QuestionType.multipleChoice;
    }
  }
}
