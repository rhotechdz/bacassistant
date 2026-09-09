import 'package:bacassistant/features/quiz/data/quiz_repository.dart';
import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:bacassistant/features/quiz/view_models/quiz_view_model.dart';
import 'package:bacassistant/features/quiz/views/quiz_page.dart';
import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:bacassistant/widgets/wrap_app_bar.dart';
import 'package:flutter/material.dart';

class QuizSubjectPage extends StatefulWidget {
  const QuizSubjectPage({super.key});

  @override
  State<QuizSubjectPage> createState() => _QuizSubjectPageState();
}

class _QuizSubjectPageState extends State<QuizSubjectPage> {
  static const subjects = [
    _QuizSubjectEntry(
      subject: 'الرياضيات',
      subtitle: 'الوحدات والأسئلة المتاحة حالياً',
      icon: Icons.functions_rounded,
    ),
    _QuizSubjectEntry(
      subject: 'العلوم الفيزيائية',
      subtitle: 'الوحدات والأسئلة المتاحة حالياً',
      icon: Icons.science_outlined,
    ),
    _QuizSubjectEntry(
      subject: 'التاريخ',
      subtitle: 'الوحدات والأسئلة المتاحة حالياً',
      icon: Icons.history_edu_outlined,
    ),
    _QuizSubjectEntry(
      subject: 'الجغرافيا',
      subtitle: 'الوحدات والأسئلة المتاحة حالياً',
      icon: Icons.public_outlined,
    ),
  ];

  late final QuizViewModel _viewModel;
  late String _selectedSubject;

  @override
  void initState() {
    super.initState();
    _selectedSubject = subjects.first.subject;
    _viewModel = QuizViewModel(repository: const QuizRepository())
      ..load(
        subject: _selectedSubject,
        field: prefs.getString('chosenField') ?? '',
      );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _selectSubject(String subject) {
    if (subject == _selectedSubject) return;
    setState(() => _selectedSubject = subject);
    _viewModel.load(
      subject: subject,
      field: prefs.getString('chosenField') ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WrapAppBar(
        title: 'اختبار جديد',
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final data = _viewModel.data;
    final availableQuestions = data == null
        ? 0
        : data.questions
            .where(
                (question) => _viewModel.selectedUnits.contains(question.unit))
            .length;
    final actualCount =
        _viewModel.questionCount.clamp(0, availableQuestions).toInt();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 78, 16, 28),
      children: [
        Text(
          'اختر المادة',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر المادة والوحدات التي تريد التدرب عليها.',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
        ),
        const SizedBox(height: 20),
        RadioGroup<String>(
          groupValue: _selectedSubject,
          onChanged: (value) {
            if (value != null) _selectSubject(value);
          },
          child: Column(
            children: subjects
                .map((entry) => _buildSubjectChoice(context, entry))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        if (_viewModel.error != null)
          Text(
            'تعذر تحميل الأسئلة: ${_viewModel.error}',
            textAlign: TextAlign.center,
          )
        else if (data == null)
          const Center(child: CircularProgressIndicator())
        else
          _buildUnitSelection(context, data, actualCount, availableQuestions),
      ],
    );
  }

  Widget _buildSubjectChoice(
    BuildContext context,
    _QuizSubjectEntry entry,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = entry.subject == _selectedSubject;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Tappable(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectSubject(entry.subject),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                entry.icon,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.subject,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      entry.subtitle,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Radio<String>(
                value: entry.subject,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelection(
    BuildContext context,
    QuizSubjectData data,
    int actualCount,
    int availableQuestions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختر الوحدات الدراسية',
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...data.units.map((unit) {
          final selected = _viewModel.selectedUnits.contains(unit.name);
          // final questionCount = data.questions.where((q) => q.unit == unit.name).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primaryContainer.withValues(alpha: 0.45)
                    : colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: CheckboxListTile(
                value: selected,
                onChanged: (_) => _viewModel.toggleUnit(unit.name),
                title: Text(
                  unit.name,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                secondary: CircleAvatar(
                  radius: 18,
                  backgroundColor: selected
                      ? colorScheme.primary
                      : colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${unit.order}',
                      style: TextStyle(
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text(
          'عدد الأسئلة: ${_viewModel.questionCount}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(trackHeight: 8),
          child: Slider(
            min: 10,
            max: 30,
            divisions: 2,
            value: _viewModel.questionCount.toDouble(),
            label: '${_viewModel.questionCount}',
            onChanged: _viewModel.setQuestionCount,
          ),
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
                  Navigator.of(context).push(
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

class _QuizSubjectEntry {
  const _QuizSubjectEntry({
    required this.subject,
    required this.subtitle,
    required this.icon,
  });

  final String subject;
  final String subtitle;
  final IconData icon;
}
