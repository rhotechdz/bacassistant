import 'dart:math';

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.unit,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String unit;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? const [])
        .map((option) => option.toString())
        .toList(growable: false);
    final correctIndex = (json['correct'] as num?)?.toInt() ?? 0;

    if (options.isEmpty || correctIndex < 0 || correctIndex >= options.length) {
      throw FormatException('Invalid quiz question: ${json['id']}');
    }

    return QuizQuestion(
      id: json['id'].toString(),
      unit: json['lesson'].toString(),
      text: json['question'].toString(),
      options: options,
      correctIndex: correctIndex,
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class QuizUnit {
  const QuizUnit({
    required this.name,
    required this.order,
    required this.weight,
  });

  final String name;
  final int order;
  final int weight;

  factory QuizUnit.fromJson(Map<String, dynamic> json) {
    return QuizUnit(
      name: json['name'].toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
    );
  }
}

class QuizSettings {
  const QuizSettings({
    required this.subject,
    required this.field,
    required this.selectedUnits,
    required this.questionCount,
  });

  final String subject;
  final String field;
  final List<String> selectedUnits;
  final int questionCount;

  Duration get timePerQuestion {
    final normalized = ((questionCount - 15) / 15).clamp(0.0, 1.0);
    final seconds = 45 - (25 * normalized).round();
    return Duration(seconds: seconds);
  }
}

class QuizResult {
  const QuizResult({
    required this.questions,
    required this.answers,
    required this.elapsed,
  });

  final List<QuizQuestion> questions;
  final List<int?> answers;
  final Duration elapsed;

  int get correctAnswers => questions.asMap().entries
      .where((entry) => answers[entry.key] == entry.value.correctIndex)
      .length;

  int get answeredCount => answers.whereType<int>().length;

  double get percentage =>
      questions.isEmpty ? 0 : correctAnswers / questions.length;
}

List<QuizQuestion> selectQuestions(
  List<QuizQuestion> questions,
  List<String> selectedUnits,
  int requestedCount,
) {
  final pool = questions
      .where((question) => selectedUnits.contains(question.unit))
      .toList();
  pool.shuffle(Random());
  return pool.take(min(requestedCount, pool.length)).toList(growable: false);
}
