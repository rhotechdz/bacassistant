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

    final rawLessons = selectedData['lessons'];
    final rawQuestions = selectedData['questions'];
    if (rawLessons is! List || rawQuestions is! List) {
      throw const FormatException('Math field data is incomplete.');
    }
    final lessons = rawLessons
        .map((lesson) => QuizUnit.fromJson(
              Map<String, dynamic>.from(lesson as Map),
            ))
        .toList(growable: false);
    final lessonNames = lessons.map((lesson) => lesson.name).toSet();
    final grouping = _unitGrouping[field] ?? _fallbackGrouping(lessons);
    final units = grouping.entries.map((entry) {
      final includedLessons =
          entry.value.where(lessonNames.contains).toList(growable: false);
      return QuizUnit(
        name: entry.key,
        order: grouping.keys.toList().indexOf(entry.key) + 1,
        weight: 1,
        lessons: includedLessons,
      );
    }).where((unit) => unit.lessons.isNotEmpty).toList(growable: false);
    final lessonToUnit = {
      for (final unit in units)
        for (final lesson in unit.lessons) lesson: unit.name,
    };

    return QuizSubjectData(
      subject: 'الرياضيات',
      field: fieldData is Map<String, dynamic> ? field : _firstFieldName(subjectData),
      units: units,
      questions: rawQuestions
          .map((question) {
            final json = Map<String, dynamic>.from(question as Map);
            return QuizQuestion.fromJson(
              json,
              unit: lessonToUnit[json['lesson'].toString()],
            );
          })
          .toList(growable: false),
    );
  }

  Future<QuizSubjectData> loadPhysicsData() async {
    final jsonString = await (_bundle ?? rootBundle)
        .loadString('assets/data/curriculum_physics.json');
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The physics curriculum must be a JSON object.');
    }
    final subjectData = decoded['العلوم الفيزيائية'];
    if (subjectData is! Map<String, dynamic>) {
      throw const FormatException('Physics subject data is missing.');
    }
    final rawUnits = subjectData['units'];
    if (rawUnits is! List) {
      throw const FormatException('Physics unit data is missing.');
    }

    final units = <QuizUnit>[];
    final questions = <QuizQuestion>[];
    for (final rawUnit in rawUnits) {
      final unitJson = Map<String, dynamic>.from(rawUnit as Map);
      final unitName = unitJson['name'].toString();
      final lesson = unitJson['lesson']?.toString() ?? unitName;
      units.add(QuizUnit(
        name: unitName,
        order: (unitJson['order'] as num?)?.toInt() ?? units.length + 1,
        weight: (unitJson['weight'] as num?)?.toInt() ?? 0,
        lessons: [lesson],
      ));
      final rawQuestions = unitJson['questions'];
      if (rawQuestions is! List) continue;
      for (final rawQuestion in rawQuestions) {
        questions.add(
          QuizQuestion.fromJson(
            Map<String, dynamic>.from(rawQuestion as Map),
            unit: unitName,
          ),
        );
      }
    }

    return QuizSubjectData(
      subject: 'العلوم الفيزيائية',
      field: 'الشعب العلمية',
      units: units,
      questions: questions,
    );
  }

  static const _unitGrouping = <String, Map<String, List<String>>>{
    'شعبة علوم تجريبية': {
      'الوحدة الأولى': [
        'الدوال العددية',
        'الدوال الأسية',
        'الدوال اللوغاريتمية',
        'التزايد المقارن',
        'المتتاليات العددية',
        'الاستدلال بالتراجع',
      ],
      'الوحدة الثانية': [
        'الدوال الأصلية',
        'الأعداد المركبة',
        'الاحتمالات',
      ],
      'الوحدة الثالثة': [
        'الحساب التكاملي',
        'الجداء السلمي',
        'المستقيمات والمستويات في الفضاء',
      ],
    },
    'شعبة رياضيات': {
      'الوحدة الأولى': [
        'الدوال العددية',
        'الدوال الأسية',
        'الدوال اللوغاريتمية',
        'التزايد المقارن',
        'المتتاليات العددية',
        'الاستدلال بالتراجع',
      ],
      'الوحدة الثانية': [
        'الدوال الأصلية والحساب التكاملي',
        'الأعداد المركبة',
        'الهندسة في المستوى المركب',
        'الحسابيات في Z',
      ],
      'الوحدة الثالثة': [
        'الاحتمالات',
        'الجداء السلمي',
        'المستقيمات والمستويات في الفضاء',
      ],
    },
    'شعبة تقني رياضي': {
      'الوحدة الأولى': [
        'الدوال العددية',
        'الدوال الأسية',
        'الدوال اللوغاريتمية',
        'التزايد المقارن',
        'المتتاليات العددية',
        'الاستدلال بالتراجع',
      ],
      'الوحدة الثانية': [
        'الدوال الأصلية والحساب التكاملي',
        'الأعداد المركبة',
        'الحسابيات في Z',
      ],
      'الوحدة الثالثة': ['الاحتمالات', 'الهندسة في الفضاء'],
    },
    'شعبة تسيير واقتصاد': {
      'الوحدة الأولى': ['الدوال العددية', 'الدالة الأسية', 'الدالة اللوغاريتمية'],
      'الوحدة الثانية': ['المتتاليات العددية', 'الاحتمالات', 'الإحصاء'],
      'الوحدة الثالثة': ['تطبيقات اقتصادية'],
    },
    'شعبة آداب وفلسفة': {
      'الوحدة الأولى': ['الدوال العددية', 'المتتاليات العددية'],
      'الوحدة الثانية': ['الاحتمالات', 'الأعداد والحساب'],
      'الوحدة الثالثة': ['الإحصاء والقراءة البيانية'],
    },
    'شعبة لغات أجنبية': {
      'الوحدة الأولى': ['الدوال العددية', 'المتتاليات العددية'],
      'الوحدة الثانية': ['الاحتمالات', 'الأعداد والحساب'],
      'الوحدة الثالثة': ['الإحصاء والقراءة البيانية'],
    },
  };

  Map<String, List<String>> _fallbackGrouping(List<QuizUnit> lessons) {
    final names = lessons.map((lesson) => lesson.name).toList();
    final firstEnd = (names.length / 3).ceil();
    final secondEnd = (names.length * 2 / 3).ceil();
    return {
      'الوحدة الأولى': names.sublist(0, firstEnd),
      'الوحدة الثانية': names.sublist(firstEnd, secondEnd),
      'الوحدة الثالثة': names.sublist(secondEnd),
    };
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
