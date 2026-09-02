import 'dart:convert';

import 'package:bacassistant/features/grade_calculator/models/score.dart';
import 'package:bacassistant/features/grade_calculator/models/subjects.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Subject to Material Icon mapping for visual categorization
const Map<String, IconData> subjectIcons = {
  'علوم الطبيعة والحياة': Icons.science_outlined,
  'الرياضيات': Icons.calculate_outlined,
  'العلوم الفيزيائية': Icons.bolt_outlined,
  'اللغة الإنجليزية': Icons.translate_outlined,
  'اللغة العربية وآدابها': Icons.translate_outlined,
  'العلوم الإسلامية': Icons.mosque_outlined,
  'التاريخ والجغرافيا': Icons.public_outlined,
  'اللغة الأمازيغية': Icons.translate_outlined,
  'التربية البدنية': Icons.sports_score_outlined,
  'الفلسفة': Icons.psychology_outlined,
  'اللغة الفرنسية': Icons.translate_outlined,
  'اللغة الألمانية': Icons.translate_outlined,
  'اللغة الإسبانية': Icons.translate_outlined,
  'اللغة الإيطالية': Icons.translate_outlined,
  'القانون': Icons.gavel_outlined,
  'التسيير المالي والمحاسبي': Icons.account_balance_outlined,
  'الاقتصاد والمناجمنت': Icons.trending_up_outlined,
  'الهندسة الميكانيكية': Icons.engineering_outlined,
  'الهندسة الكهربائية': Icons.electrical_services_outlined,
  'الهندسة المدنية': Icons.architecture_outlined,
  'هندسة الطرائق': Icons.engineering_outlined,
  'الإعلام الآلي': Icons.computer_outlined,
  'التاريخ و الجغرافيا': Icons.public_outlined,
};

class GradeCalculatorPage extends StatefulWidget {
  const GradeCalculatorPage({super.key});

  @override
  State<GradeCalculatorPage> createState() => _GradeCalculatorPageState();
}

class _GradeCalculatorPageState extends State<GradeCalculatorPage> {
  late Subjects subjects;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    subjects = Subjects();
    _syncInputs();
  }

  void _syncInputs() {
    for (final entry in [
      ...subjects.map.entries,
      ...subjects.optional.entries.map(
        (entry) => MapEntry(entry.key, entry.value[0] as int),
      ),
    ]) {
      _controllers.putIfAbsent(entry.key, TextEditingController.new);
      _focusNodes.putIfAbsent(entry.key, FocusNode.new);
    }
  }

  void _toggle(String key) {
    setState(() {
      subjects.update(key);
      subjects.unify();
      _syncInputs();
      FocusScope.of(context).unfocus();
    });
  }

  bool _isGradeValueInvalid(String value) {
    if (value.trim().isEmpty) {
      return false;
    }

    final parsed = double.tryParse(value);
    return parsed == null || parsed < 0 || parsed > 20;
  }

  void _moveToNextField(String currentKey) {
    final keys = _controllers.keys.toList();
    final index = keys.indexOf(currentKey);

    if (index == -1) {
      return;
    }

    if (_isGradeValueInvalid(_controllers[currentKey]!.text)) {
      _focusNodes[currentKey]?.requestFocus();
      return;
    }

    if (index < keys.length - 1) {
      final nextKey = keys[index + 1];
      FocusScope.of(context).requestFocus(_focusNodes[nextKey]);
    } else {
      _focusNodes[currentKey]?.unfocus();
    }
  }

  void _saveAndShowResult() {
    final GPAModel gpaModel = GPAModel();

    for (final entry in subjects.unified.entries) {
      final value = _controllers[entry.key]?.text.trim() ?? '';
      if (value.isEmpty) {
        continue;
      }

      final points = double.tryParse(value);
      if (points == null || points < 0 || points > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى إدخال نقاط صحيحة لكل مادة (${entry.key})'),
          ),
        );
        return;
      }

      gpaModel.scoreMap[entry.key] = {
        'points': points,
        'factor': entry.value,
      };
    }

    if (gpaModel.scoreMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال نقاط على الأقل لمادة واحدة')),
      );
      return;
    }

    gpaModel.scoreMap['GPA'] = gpaModel.calculateAverage();
    gpaModel.saveResult();

    final average = gpaModel.calculateAverage();
    final (resultLabel, resultColor, resultIcon) = switch (average) {
      >= 16 => ('ممتاز', Colors.green, Icons.emoji_events_rounded),
      >= 14 => ('جيد جدا', Colors.teal, Icons.thumb_up_alt_rounded),
      >= 12 => ('جيد', Colors.blue, Icons.check_circle_rounded),
      >= 10 => ('مقبول', Colors.orange, Icons.trending_up_rounded),
      _ => ('راسب', Colors.red, Icons.sentiment_dissatisfied_rounded),
    };
    showDialog(
      context: context,
      builder: (context) {
        final resultTextColor = ThemeData.estimateBrightnessForColor(
                  resultColor,
                ) ==
                Brightness.dark
            ? Colors.white
            : Colors.black87;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          title: Row(
            children: [
              Icon(resultIcon, color: resultColor),
              const SizedBox(width: 10),
              const Text('المعدل النهائي'),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: resultColor.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.28
                    : 0.14,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: resultColor.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  average.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: resultColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: resultColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    resultLabel,
                    style: TextStyle(
                      color: resultTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسنا'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistorySheet() {
    final recordsRaw = prefs.getString('GPA_records');
    if (recordsRaw == null || recordsRaw.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('لا توجد سجلات سابقة'),
        ),
      );
    }

    final Map<String, dynamic> recordsMap = jsonDecode(recordsRaw);

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'السجلات السابقة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final entry in recordsMap.entries)
                ListTile(
                  onTap: () {
                    final result = entry.value as Map<String, dynamic>;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تفاصيل النتيجة'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعدل: ${(result['GPA'] as num).toDouble().toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
                            for (final item in result.entries)
                              if (item.key != 'GPA')
                                Text(
                                  '${item.key}: ${item.value['points']} (عامل: ${item.value['factor']})',
                                ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('إغلاق'),
                          ),
                        ],
                      ),
                    );
                  },
                  title: Text(
                    (entry.value['GPA'] as num).toDouble().toStringAsFixed(2),
                    textAlign: TextAlign.end,
                  ),
                  subtitle: Text(
                    DateTime.fromMillisecondsSinceEpoch(int.parse(entry.key))
                        .toLocal()
                        .toString()
                        .split(' ')
                        .first,
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectEntries = [
      ...subjects.map.entries,
      ...subjects.optional.entries.map(
        (entry) => MapEntry(entry.key, entry.value[0] as int),
      ),
    ];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب المعدل'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: _buildHistorySheet(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  // Mandatory subjects card
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: subjectEntries.asMap().entries.map((item) {
                        final entry = item.value;
                        final controller = _controllers[entry.key]!;
                        final focusNode = _focusNodes[entry.key]!;
                        final icon =
                            subjectIcons[entry.key] ?? Icons.school_outlined;
                        final isOptional =
                            subjects.optional.containsKey(entry.key);
                        final isEnabled = !isOptional ||
                            subjects.unified.containsKey(entry.key);

                        return RepaintBoundary(
                          key: ValueKey(entry.key),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap:
                                  isOptional ? () => _toggle(entry.key) : null,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Subject info with icon
                                        Expanded(
                                          child: Row(
                                            children: [
                                              // Subject icon in circular badge
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isEnabled
                                                      ? colorScheme
                                                          .primaryContainer
                                                      : colorScheme
                                                          .surfaceContainerHighest,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  icon,
                                                  color: isEnabled
                                                      ? colorScheme
                                                          .onPrimaryContainer
                                                      : colorScheme
                                                          .onSurfaceVariant,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Subject name and factor
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            entry.key,
                                                            style: textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: isEnabled
                                                                  ? colorScheme
                                                                      .onSurface
                                                                  : colorScheme
                                                                      .onSurfaceVariant,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        if (isOptional)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 6),
                                                            child: Icon(
                                                              Icons
                                                                  .touch_app_outlined,
                                                              size: 16,
                                                              color: colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Text(
                                                      'المعامل: ${entry.value}',
                                                      style: textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Input field
                                        SizedBox(
                                          width: 96,
                                          child: ValueListenableBuilder<
                                              TextEditingValue>(
                                            valueListenable: controller,
                                            builder: (context, value, child) =>
                                                TextField(
                                              enabled: isEnabled,
                                              focusNode: focusNode,
                                              controller: controller,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              textAlign: TextAlign.center,
                                              textDirection: TextDirection.ltr,
                                              textInputAction: item.key ==
                                                      subjectEntries.length - 1
                                                  ? TextInputAction.done
                                                  : TextInputAction.next,
                                              onSubmitted: (_) =>
                                                  _moveToNextField(entry.key),
                                              onChanged: (value) {
                                                if (_isGradeValueInvalid(
                                                    value)) {
                                                  focusNode.requestFocus();
                                                }
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                  RegExp(r'^\d*\.?\d{0,2}$'),
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: '0 - 20',
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.outline,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: _isGradeValueInvalid(
                                                            controller.text)
                                                        ? colorScheme.error
                                                        : colorScheme.outline,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: _isGradeValueInvalid(
                                                            controller.text)
                                                        ? colorScheme.error
                                                        : colorScheme.primary,
                                                    width: 2,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.error,
                                                  ),
                                                ),
                                                focusedErrorBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.error,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Divider between rows
                                  if (item.key < subjectEntries.length - 1)
                                    Divider(
                                      height: 1,
                                      color: colorScheme.outlineVariant
                                          .withValues(alpha: 0.3),
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    Color.lerp(
                          colorScheme.primary,
                          colorScheme.secondary,
                          0.35,
                        ) ??
                        colorScheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _saveAndShowResult,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('احسب المعدل'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colorScheme.onPrimary,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
