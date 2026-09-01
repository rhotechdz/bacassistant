import 'package:bacassistant/features/BAC/screens/bac_doc_page.dart';
import 'package:bacassistant/features/grade_calculator/screens/grade_calculator.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFFF7EEFF),
        elevation: 0,
        title: Text(
          'مواضيع البكالوريا',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1924),
              ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_forward_rounded, size: 28),
          color: const Color(0xFF1E1924),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'اختر دورة البكالوريا للإطلاع على المواضيع والحلول المفصلة.',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4C4355),
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: years.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final year = years[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BacSubjectSelectionPage(year: year),
                          ),
                        );
                      },
                      child: Container(
                        height: 90,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE5F4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chevron_left_rounded,
                              size: 28,
                              color: Color(0xFF1E1924),
                            ),
                            const SizedBox(width: 12),
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
                                          color: const Color(0xFF1E1924),
                                        ),
                                  ),
                                  Text(
                                    'شعبة علوم تجريبية',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: const Color(0xFF4C4355),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B2CF5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  @override
  void initState() {
    super.initState();
    field = prefs.getString('chosenField') ?? fieldDict.keys.first;
  }

  List<String> get subjects =>
      (subjectsMap[field] as Map<String, dynamic>).keys.cast<String>().toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF7EEFF),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'اختر المادة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1924),
                  ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_forward_rounded, size: 28),
            color: const Color(0xFF1E1924),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر المادة للاطلاع على المواضيع والحلول',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4C4355),
                        height: 1.6,
                      ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: subjects.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final icon = _subjectIcon(subject);

                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        prefs.setString('chosenSubject', subject);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BacDocViewer(
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
                          color: const Color(0xFFEFE5F4),
                          borderRadius: BorderRadius.circular(18),
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
                                      color: const Color(0xFF1E1924),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B2CF5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                              ),
                              child: Icon(icon, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                      ),
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
