import 'package:bacassistant/features/quiz/data/quiz_repository.dart';
import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:flutter/foundation.dart';

class QuizViewModel extends ChangeNotifier {
  QuizViewModel({required QuizRepository repository}) : _repository = repository;

  final QuizRepository _repository;
  QuizSubjectData? _data;
  Object? _error;
  Set<String> _selectedUnits = {};
  int _questionCount = 15;

  QuizSubjectData? get data => _data;
  Object? get error => _error;
  Set<String> get selectedUnits => Set.unmodifiable(_selectedUnits);
  int get questionCount => _questionCount;

  Future<void> load({required String subject, required String field}) async {
    try {
      _error = null;
      _data = subject == 'العلوم الفيزيائية'
          ? await _repository.loadPhysicsData()
          : subject == 'التاريخ' || subject == 'الجغرافيا'
              ? await _repository.loadHistoryGeographyData(subject: subject)
          : await _repository.loadMathData(field: field);
      _selectedUnits = _data!.units.map((unit) => unit.name).toSet();
      _questionCount = _questionCount.clamp(15, 30);
    } catch (error) {
      _error = error;
    }
    notifyListeners();
  }

  void toggleUnit(String unit) {
    if (_selectedUnits.contains(unit) && _selectedUnits.length == 1) return;
    _selectedUnits = {..._selectedUnits}..toggle(unit);
    notifyListeners();
  }

  void setQuestionCount(double value) {
    _questionCount = value.round().clamp(15, 30);
    notifyListeners();
  }

  List<QuizQuestion> buildQuiz() {
    final data = _data;
    if (data == null) return const [];
    return selectQuestions(data.questions, _selectedUnits.toList(), _questionCount);
  }
}

extension on Set<String> {
  void toggle(String value) {
    contains(value) ? remove(value) : add(value);
  }
}
