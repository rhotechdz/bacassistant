import 'package:bacassistant/features/BAC/screens/bac_doc_page.dart';
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
    final String selectedField =
        prefs.getString('chosenField') ?? fieldDict.keys.first;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            color: const Color(0xFF1E1924),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('اختر الشعبة'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: fieldDict.keys.length,
                        itemBuilder: (context, index) {
                          final field = fieldDict.keys.toList()[index];
                          final isSelected = field == selectedField;
                          return ListTile(
                            title: Text(field),
                            trailing:
                                isSelected ? const Icon(Icons.check) : null,
                            onTap: () {
                              prefs.setString('chosenField', field);
                              final firstSubject =
                                  (subjectsMap[field] as Map).keys.first;
                              prefs.setString('chosenSubject', firstSubject);
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 28),
              color: const Color(0xFF1E1924),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر دورة البكالوريا للإطلاع على المواضيع والحلول المفصلة لشعبة $selectedField.',
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      selectedField,
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
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 28,
                                color: Color(0xFF1E1924),
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
      appBar: AppBar(
        title: const Text('Choose subject'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<String>(
              initialValue: field,
              decoration: const InputDecoration(labelText: 'Field'),
              items: fieldDict.keys
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  field = value;
                  prefs.setString('chosenField', value);
                  final firstSubject = (subjectsMap[value] as Map).keys.first;
                  prefs.setString('chosenSubject', firstSubject);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Card(
                  child: ListTile(
                    title: Text(subject),
                    trailing: const Icon(Icons.chevron_right),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
