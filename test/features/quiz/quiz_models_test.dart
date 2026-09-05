import 'dart:math';

import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizQuestion', () {
    test('parses a multiple choice question', () {
      final question = QuizQuestion.fromJson({
        'id': 'q1',
        'lesson': 'الدوال',
        'question': 'ما قيمة 1 + 1؟',
        'options': ['1', '2'],
        'correct': 1,
        'explanation': 'الجمع.',
      });

      expect(question.correctIndex, 1);
      expect(question.options, ['1', '2']);
    });
  });

  test('time per question decreases as question count increases', () {
    final shortQuiz = QuizSettings(
      subject: 'الرياضيات',
      field: 'شعبة رياضيات',
      selectedUnits: const ['الدوال'],
      questionCount: 15,
    );
    final longQuiz = QuizSettings(
      subject: 'الرياضيات',
      field: 'شعبة رياضيات',
      selectedUnits: const ['الدوال'],
      questionCount: 30,
    );

    expect(shortQuiz.timePerQuestion.inSeconds, greaterThan(longQuiz.timePerQuestion.inSeconds));
  });

  test('randomizes options while preserving the correct answer', () {
    final question = QuizQuestion.fromJson({
      'id': 'q1',
      'lesson': 'الدوال',
      'question': 'ما قيمة 1 + 1؟',
      'options': ['1', '2', '3', '4'],
      'correct': 1,
      'explanation': 'الجمع.',
    });

    final randomized = randomizeQuestionOptions(question, Random(7));

    expect(randomized.options, contains('2'));
    expect(randomized.options[randomized.correctIndex], '2');
    expect(randomized.options, isNot(equals(question.options)));
  });
}
