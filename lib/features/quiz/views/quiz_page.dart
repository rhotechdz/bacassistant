import 'dart:async';

import 'package:bacassistant/features/quiz/models/quiz_models.dart';
import 'package:bacassistant/features/quiz/views/quiz_results_page.dart';
import 'package:bacassistant/utils/initializer.dart';
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
  var _isExitDialogOpen = false;
  var _isFinishing = false;
  late int _remainingSeconds;
  late final DateTime _startedAt;

  QuizQuestion get _question => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.questions.length, null);
    _remainingSeconds = widget.settings.timePerQuestion.inSeconds;
    _startedAt = DateTime.now();
    adService.beginFullScreenContent();
    adService.loadRewardedInterstitialAd();
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

  Future<void> _finish() async {
    if (_isFinishing) {
      return;
    }
    _isFinishing = true;
    _timer?.cancel();
    final result = QuizResult(
      questions: widget.questions,
      answers: _answers,
      elapsed: DateTime.now().difference(_startedAt),
    );
    var resultsShown = false;

    void showResults() {
      if (!mounted || resultsShown) {
        return;
      }
      resultsShown = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => QuizResultsPage(result: result),
        ),
      );
    }

    final shouldShowAd =
        await adService.shouldShowTriggerAd(prefs, 'quizAdCounter');
    adService.endFullScreenContent();
    if (!shouldShowAd || !adService.isRewardedInterstitialAdAvailable) {
      showResults();
      return;
    }

    final didShowAd = await adService.showRewardedInterstitialAd(
      onDismissed: showResults,
      onFailedToShow: (_, __) => showResults(),
    );
    if (!didShowAd) {
      showResults();
    }
  }

  Future<void> _confirmExit() async {
    if (_isExitDialogOpen || !mounted) return;
    _isExitDialogOpen = true;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          title: const Text(
            'مغادرة الاختبار؟',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'سيتم فقدان تقدمك الحالي ولن يتم احتساب نتيجة هذا الاختبار.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('متابعة'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('مغادرة'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    _isExitDialogOpen = false;
    if (shouldExit == true && mounted) {
      _timer?.cancel();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    adService.endFullScreenContent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAnswer = _answers[_currentIndex];
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _remainingSeconds /
                      widget.settings.timePerQuestion.inSeconds,
                  strokeWidth: 3,
                ),
                Text(
                  '$_remainingSeconds',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _confirmExit,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_currentIndex + 1} / ${widget.questions.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 80,
                  ),
                  child: Text(
                    _question.unit,
                    softWrap: true,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(
                        () => _answers[_currentIndex] = entry.key,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: selectedAnswer == entry.key
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selectedAnswer == entry.key
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: selectedAnswer == entry.key ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedAnswer == entry.key
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: selectedAnswer == entry.key
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.right,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
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
      ),
    );
  }
}
