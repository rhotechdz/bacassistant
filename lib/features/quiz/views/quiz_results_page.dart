import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:flutter/material.dart';

class QuizResultsPage extends StatelessWidget {
  const QuizResultsPage({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final percentage = (result.percentage * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة الاختبار')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('$percentage%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(height: 8),
                  Text('${result.correctAnswers} من ${result.questions.length} إجابات صحيحة'),
                  Text('تمت الإجابة عن ${result.answeredCount} أسئلة'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...result.questions.asMap().entries.map(
                (entry) {
                  final question = entry.value;
                  final answer = result.answers[entry.key];
                  final correct = answer == question.correctIndex;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        correct ? Icons.check_circle : Icons.cancel,
                        color: correct ? Colors.green : Colors.red,
                      ),
                      title: Text(question.text),
                      subtitle: Text(
                        answer == null
                            ? 'لم تتم الإجابة\nالإجابة الصحيحة: ${question.options[question.correctIndex]}'
                            : correct
                                ? 'إجابة صحيحة'
                                : 'الإجابة الصحيحة: ${question.options[question.correctIndex]}\n${question.explanation}',
                      ),
                    ),
                  );
                },
              ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context)
                .popUntil((route) => route.isFirst),
            child: const Text('العودة إلى الرئيسية'),
          ),
        ],
      ),
    );
  }
}
