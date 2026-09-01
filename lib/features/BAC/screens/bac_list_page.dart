
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
  final List<int> years = List<int>.generate(2023 - 2012 + 1, (index) => 2012 + index);

  @override
  Widget build(BuildContext context) {
    final String selectedField = prefs.getString('chosenField') ?? fieldDict.keys.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose year'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<String>(
              value: selectedField,
              underline: const SizedBox(),
              items: fieldDict.keys
                  .map(
                    (field) => DropdownMenuItem<String>(
                      value: field,
                      child: Text(field),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                prefs.setString('chosenField', value);
                final firstSubject = (subjectsMap[value] as Map).keys.first;
                prefs.setString('chosenSubject', firstSubject);
                setState(() {});
              },
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: years.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final year = years[index];
          return FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BacSubjectSelectionPage(year: year),
                ),
              );
            },
            child: Text(
              'Bac $year',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        },
      ),
    );
  }
}

class BacSubjectSelectionPage extends StatefulWidget {
  final int year;

  const BacSubjectSelectionPage({super.key, required this.year});

  @override
  State<BacSubjectSelectionPage> createState() => _BacSubjectSelectionPageState();
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