import 'package:bacassistant/features/quiz/views/quiz_setup_page.dart';
import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuizSubjectPage extends StatelessWidget {
  const QuizSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const subjects = [
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
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'اختبار جديد',
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'اختر المادة',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر المادة التي تريد التدرب عليها.',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 20),
            ...subjects.asMap().entries.map(
              (item) {
                final entry = item.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Tappable(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuizSetupPage(subject: entry.subject),
                      ),
                    ),
                    child: _buildSubjectEntry(context, colorScheme, entry),
                  ).animate(
                    delay: Duration(milliseconds: 25 * item.key),
                    effects: const [
                      FadeEffect(duration: Duration(milliseconds: 250)),
                      SlideEffect(
                        begin: Offset(0, 0.08),
                        end: Offset.zero,
                        duration: Duration(milliseconds: 250),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectEntry(
    BuildContext context,
    ColorScheme colorScheme,
    _QuizSubjectEntry entry,
  ) {
    return Container(
                height: 92,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 24,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.subject,
                            textAlign: TextAlign.right,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            entry.subtitle,
                            textAlign: TextAlign.right,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        entry.icon,
                        color: colorScheme.onPrimaryContainer,
                        size: 27,
                      ),
                    ),
                  ],
                ),
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
