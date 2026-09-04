import 'dart:convert';

import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:flutter/services.dart';

class QuizRepository {
  const QuizRepository({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  Future<QuizSubjectData> loadMathData({required String field}) async {
    final jsonString = await (_bundle ?? rootBundle)
        .loadString('assets/data/curriculum_math.json');
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The math curriculum must be a JSON object.');
    }

    final subjectData = decoded['الرياضيات'];
    if (subjectData is! Map<String, dynamic>) {
      throw const FormatException('Math subject data is missing.');
    }

    final fieldData = subjectData[field];
    final fallbackField = subjectData.values.firstWhere(
      (value) => value is Map<String, dynamic>,
      orElse: () => null,
    );
    final selectedData = fieldData is Map<String, dynamic>
        ? fieldData
        : (fallbackField is Map<String, dynamic> ? fallbackField : null);
    if (selectedData == null) {
      throw const FormatException('No math field data is available.');
    }

    final rawUnits = selectedData['lessons'];
    final rawQuestions = selectedData['questions'];
    if (rawUnits is! List || rawQuestions is! List) {
      throw const FormatException('Math field data is incomplete.');
    }

    return QuizSubjectData(
      subject: 'الرياضيات',
      field: fieldData is Map<String, dynamic> ? field : _firstFieldName(subjectData),
      units: rawUnits
          .map((unit) => QuizUnit.fromJson(Map<String, dynamic>.from(unit as Map)))
          .toList(growable: false),
      questions: rawQuestions
          .map((question) =>
              QuizQuestion.fromJson(Map<String, dynamic>.from(question as Map)))
          .toList(growable: false),
    );
  }

  String _firstFieldName(Map<String, dynamic> subjectData) {
    return subjectData.keys.first;
  }
}

class QuizSubjectData {
  const QuizSubjectData({
    required this.subject,
    required this.field,
    required this.units,
    required this.questions,
  });

  final String subject;
  final String field;
  final List<QuizUnit> units;
  final List<QuizQuestion> questions;
}
