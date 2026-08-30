import 'dart:convert';

import 'package:bacassistant/features/grade_calculator/models/score.dart';
import 'package:bacassistant/features/grade_calculator/models/subjects.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    _controllers.clear();
    _focusNodes.clear();

    for (final entry in subjects.unified.entries) {
      _controllers[entry.key] = TextEditingController();
      _focusNodes[entry.key] = FocusNode();
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
    final keys = subjects.unified.keys.toList();
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المعدل النهائي'),
        content: Text(
          gpaModel.calculateAverage().toStringAsFixed(2),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسنا'),
          ),
        ],
      ),
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
    final optionalEntries = subjects.optional.entries.toList();
    final subjectEntries = subjects.unified.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب المعدل'),
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
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'أدخل نقاطك لكل مادة',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      ...subjectEntries.map((entry) {
                        final controller =
                            _controllers[entry.key] ?? TextEditingController();
                        final focusNode = _focusNodes[entry.key] ?? FocusNode();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${entry.key} (${entry.value})',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 110,
                                child: TextField(
                                  focusNode: focusNode,
                                  controller: controller,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                  textInputAction:
                                      subjectEntries.indexOf(entry) ==
                                              subjectEntries.length - 1
                                          ? TextInputAction.done
                                          : TextInputAction.next,
                                  onSubmitted: (_) =>
                                      _moveToNextField(entry.key),
                                  onChanged: (value) {
                                    final isInvalid =
                                        _isGradeValueInvalid(value);
                                    if (isInvalid) {
                                      final currentField =
                                          _focusNodes[entry.key];
                                      if (currentField != null) {
                                        currentField.requestFocus();
                                      }
                                    }
                                    setState(() {});
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '0-20',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    helperText:
                                        _isGradeValueInvalid(controller.text)
                                            ? 'القيمة لا تتجاوز 20'
                                            : null,
                                    helperStyle: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11,
                                    ),
                                    border: const OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _isGradeValueInvalid(
                                                controller.text)
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: _isGradeValueInvalid(
                                                controller.text)
                                            ? Colors.red
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                      ),
                                    ),
                                    errorBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    focusedErrorBorder:
                                        const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 18),
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'مواد اختيارية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...optionalEntries.map((entry) {
                        final isEnabled = entry.value[1] as bool;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: isEnabled,
                            onChanged: (_) => _toggle(entry.key),
                            title: Text(
                              '${entry.key} (${entry.value[0]})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveAndShowResult,
                    icon: const Icon(Icons.calculate_rounded),
                    label: const Text('احسب المعدل'),
                  ),
                ),
              ],
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
