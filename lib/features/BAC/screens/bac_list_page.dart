import 'package:bacassistant/features/BAC/screens/bac_doc_page.dart';
import 'package:bacassistant/features/BAC/services/bac_availability_service.dart';
import 'package:bacassistant/features/grade_calculator/screens/grade_calculator.dart';
import 'package:bacassistant/routes.dart';
import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:bacassistant/widgets/wrap_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const _bacListItemAnimationDelay = 25;

class BacPage extends StatefulWidget {
  const BacPage({super.key});

  @override
  State<BacPage> createState() => _BacPageState();
}

class _BacPageState extends State<BacPage> {
  late final List<int> years;

  _BacPageState() {
    years = List<int>.generate(2023 - 2012 + 1, (index) => 2023 - index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedField =
        prefs.getString('chosenField') ?? fieldDict.keys.first;

    return Scaffold(
      body: WrapAppBar(
        title: 'مواضيع البكالوريا',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 78),
                  itemCount: years.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final year = years[index];

                    return Tappable(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          drillDown(BacSubjectSelectionPage(year: year)),
                        );
                      },
                      child: Container(
                        height: 84,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
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
                                    'بكالوريا $year',
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
                                    selectedField,
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
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: colorScheme.onPrimaryContainer,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(
                      delay: Duration(
                        milliseconds: _bacListItemAnimationDelay * index,
                      ),
                      effects: const [
                        FadeEffect(duration: Duration(milliseconds: 250)),
                        SlideEffect(
                          begin: Offset(0, 0.08),
                          end: Offset.zero,
                          duration: Duration(milliseconds: 250),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BacSubjectSelectionPage extends StatefulWidget {
  final int year;

  const BacSubjectSelectionPage({super.key, required this.year});

  @override
  State<BacSubjectSelectionPage> createState() =>
      _BacSubjectSelectionPageState();
}

class _BacSubjectSelectionPageState extends State<BacSubjectSelectionPage> {
  late String field;
  late Future<List<String>> _subjectsFuture;

  @override
  void initState() {
    super.initState();
    field = prefs.getString('chosenField') ?? fieldDict.keys.first;
    _loadSubjects();
  }

  void _loadSubjects() {
    _subjectsFuture = BacAvailabilityService().subjectsFor(
      year: widget.year,
      field: field,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: WrapAppBar(
        title: 'بكالوريا ${widget.year}',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 78, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _subjectsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _SubjectsError(
                        onRetry: () => setState(_loadSubjects),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final subjects = snapshot.data!;
                    if (subjects.isEmpty) {
                      return const Center(
                        child: Text('لا توجد مواضيع متاحة لهذه الشعبة.'),
                      );
                    }

                    return ListView.separated(
                      itemCount: subjects.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final icon = _subjectIcon(subject);

                        return Tappable(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            prefs.setString('chosenSubject', subject);
                            Navigator.push(
                              context,
                              drillDown(
                                BacDocViewer(
                                  year: widget.year,
                                  subject: subject,
                                  field: field,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 84,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject,
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 26,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate(
                          delay: Duration(
                            milliseconds: _bacListItemAnimationDelay * index,
                          ),
                          effects: const [
                            FadeEffect(duration: Duration(milliseconds: 250)),
                            SlideEffect(
                              begin: Offset(0, 0.08),
                              end: Offset.zero,
                              duration: Duration(milliseconds: 250),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _subjectIcon(String subject) {
    final normalized = subject.trim();
    return subjectIcons[normalized] ?? Icons.school_outlined;
  }
}

class _SubjectsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _SubjectsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('تعذر تحميل المواضيع المتاحة.'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
