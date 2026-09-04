import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:flutter/material.dart';

class QuizResultsPage extends StatelessWidget {
  const QuizResultsPage({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (result.percentage * 100).round();
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'نتيجة الاختبار',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_forward_rounded, size: 28),
            color: colorScheme.onSurface,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.correctAnswers} من ${result.questions.length} إجابات صحيحة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'تمت الإجابة عن ${result.answeredCount} أسئلة',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'مراجعة الإجابات',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...result.questions.asMap().entries.map(
                (entry) {
                  final question = entry.value;
                  final answer = result.answers[entry.key];
                  final correct = answer == question.correctIndex;
                  final statusColor =
                      correct ? colorScheme.primary : colorScheme.error;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: correct
                            ? colorScheme.outlineVariant
                            : colorScheme.error.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          correct
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: statusColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                question.text,
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                answer == null
                                    ? 'لم تتم الإجابة\nالإجابة الصحيحة: ${question.options[question.correctIndex]}'
                                    : correct
                                        ? 'إجابة صحيحة'
                                        : 'الإجابة الصحيحة: ${question.options[question.correctIndex]}\n${question.explanation}',
                                textAlign: TextAlign.right,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
