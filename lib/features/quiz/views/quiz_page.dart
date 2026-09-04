import 'dart:async';

import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:bacassistant/features/quiz/views/quiz_results_page.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.questions, required this.settings});

  final List<QuizQuestion> questions;
  final QuizSettings settings;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final List<int?> _answers;
  Timer? _timer;
  var _currentIndex = 0;
  late int _remainingSeconds;
  late final DateTime _startedAt;

  QuizQuestion get _question => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.questions.length, null);
    _remainingSeconds = widget.settings.timePerQuestion.inSeconds;
    _startedAt = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _next();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _next() {
    if (_currentIndex == widget.questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _currentIndex++;
      _remainingSeconds = widget.settings.timePerQuestion.inSeconds;
    });
    _startTimer();
  }

  void _finish() {
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => QuizResultsPage(
          result: QuizResult(
            questions: widget.questions,
            answers: _answers,
            elapsed: DateTime.now().difference(_startedAt),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAnswer = _answers[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${widget.questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / widget.questions.length,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(label: Text(_question.unit)),
              Text('$_remainingSeconds ث'),
            ],
          ),
          const SizedBox(height: 20),
          Text(_question.text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 20),
          ..._question.options.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      title: Text(entry.value),
                      leading: Icon(
                        selectedAnswer == entry.key
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selectedAnswer == entry.key
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onTap: () => setState(
                        () => _answers[_currentIndex] = entry.key,
                      ),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: selectedAnswer == null ? null : _next,
            child: Text(_currentIndex == widget.questions.length - 1
                ? 'إنهاء الاختبار'
                : 'السؤال التالي'),
          ),
        ],
      ),
    );
  }
}
