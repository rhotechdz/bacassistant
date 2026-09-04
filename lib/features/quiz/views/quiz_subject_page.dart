import 'package:bacassistant/features/quiz/views/quiz_setup_page.dart';
import 'package:flutter/material.dart';

class QuizSubjectPage extends StatelessWidget {
  const QuizSubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار جديد')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'اختر المادة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('اختر المادة التي تريد التدرب عليها.'),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.functions_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('الرياضيات'),
              subtitle: const Text('الوحدات والأسئلة المتاحة حالياً'),
              trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const QuizSetupPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
