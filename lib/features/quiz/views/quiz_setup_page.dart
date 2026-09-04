import 'package:bacassistant/features/quiz/data/quiz_repository.dart';
import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:bacassistant/features/quiz/view_models/quiz_view_model.dart';
import 'package:bacassistant/features/quiz/views/quiz_page.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';

class QuizSetupPage extends StatefulWidget {
  const QuizSetupPage({super.key});

  @override
  State<QuizSetupPage> createState() => _QuizSetupPageState();
}

class _QuizSetupPageState extends State<QuizSetupPage> {
  late final QuizViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = QuizViewModel(repository: const QuizRepository())
      ..load(field: prefs.getString('chosenField') ?? '');
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد الاختبار')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.error != null) {
            return Center(child: Text('تعذر تحميل الأسئلة: ${_viewModel.error}'));
          }
          final data = _viewModel.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildContent(context, data);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuizSubjectData data) {
    final availableQuestions = data.questions
        .where((question) => _viewModel.selectedUnits.contains(question.unit))
        .length;
    final actualCount =
        _viewModel.questionCount.clamp(0, availableQuestions).toInt();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Text(data.subject,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        Text('الشعبة: ${data.field}'),
        const SizedBox(height: 24),
        Text('اختر الوحدات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        const SizedBox(height: 8),
        ...data.units.map(
          (unit) => CheckboxListTile(
            value: _viewModel.selectedUnits.contains(unit.name),
            title: Text(unit.name),
            subtitle: Text('${data.questions.where((q) => q.unit == unit.name).length} أسئلة'),
            onChanged: (_) => _viewModel.toggleUnit(unit.name),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Text('عدد الأسئلة: ${_viewModel.questionCount}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
        Slider(
          min: 15,
          max: 30,
          divisions: 15,
          value: _viewModel.questionCount.toDouble(),
          label: '${_viewModel.questionCount}',
          onChanged: _viewModel.setQuestionCount,
        ),
        Text(
          'الوقت لكل سؤال: ${QuizSettings(subject: data.subject, field: data.field, selectedUnits: _viewModel.selectedUnits.toList(), questionCount: _viewModel.questionCount).timePerQuestion.inSeconds} ثانية',
          textAlign: TextAlign.center,
        ),
        if (availableQuestions < _viewModel.questionCount)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'ستظهر $actualCount أسئلة لأن الوحدات المختارة تحتوي على $availableQuestions فقط.',
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: actualCount == 0
              ? null
              : () {
                  final questions = _viewModel.buildQuiz();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => QuizPage(
                        questions: questions,
                        settings: QuizSettings(
                          subject: data.subject,
                          field: data.field,
                          selectedUnits: _viewModel.selectedUnits.toList(),
                          questionCount: _viewModel.questionCount,
                        ),
                      ),
                    ),
                  );
                },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('ابدأ الاختبار'),
        ),
      ],
    );
  }
}
