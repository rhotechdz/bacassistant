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
  'اللغة الإنجليزية': Icons.language_outlined,
  'اللغة العربية وآدابها': Icons.language_outlined,
  'العلوم الإسلامية': Icons.mosque_outlined,
  'التاريخ والجغرافيا': Icons.public_outlined,
  'اللغة الأمازيغية': Icons.language_outlined,
  'التربية البدنية': Icons.sports_score_outlined,
  'الفلسفة': Icons.psychology_outlined,
  'اللغة الفرنسية': Icons.language_outlined,
  'اللغة الألمانية': Icons.language_outlined,
  'اللغة الإسبانية': Icons.language_outlined,
  'اللغة الإيطالية': Icons.language_outlined,
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
    final colorScheme = Theme.of(context).colorScheme;

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
        child: Directionality(
          textDirection: TextDirection.rtl,
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
                    // Descriptive caption
                    Center(
                      child: Text(
                        'خطوة بخطوة نحو النجاح، كل نقطة تصنع الفارق!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Mandatory subjects card
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: subjectEntries.map((entry) {
                          final controller = _controllers[entry.key] ??
                              TextEditingController();
                          final focusNode =
                              _focusNodes[entry.key] ?? FocusNode();
                          final icon =
                              subjectIcons[entry.key] ?? Icons.school_outlined;

                          return Column(
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
                                              color:
                                                  colorScheme.primaryContainer,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              icon,
                                              color: colorScheme
                                                  .onPrimaryContainer,
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
                                                Text(
                                                  entry.key,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: colorScheme
                                                            .onSurface,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'المعامل: ${entry.value}',
                                                  style: Theme.of(context)
                                                      .textTheme
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
                                      child: TextField(
                                        focusNode: focusNode,
                                        controller: controller,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
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
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                              color: _isGradeValueInvalid(
                                                      controller.text)
                                                  ? colorScheme.error
                                                  : colorScheme.outline,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
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
                                  ],
                                ),
                              ),
                              // Divider between rows
                              if (subjectEntries.indexOf(entry) <
                                  subjectEntries.length - 1)
                                Divider(
                                  height: 1,
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.3),
                                  indent: 16,
                                  endIndent: 16,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Optional subjects section
                    if (optionalEntries.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                12,
                              ),
                              child: Text(
                                'مواد اختيارية',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Column(
                                children: optionalEntries.map((entry) {
                                  final isEnabled = entry.value[1] as bool;
                                  final icon = subjectIcons[entry.key] ??
                                      Icons.school_outlined;

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 0,
                                      ),
                                      leading: Icon(
                                        icon,
                                        color: colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      title: Text(
                                        entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                      trailing: Checkbox(
                                        value: isEnabled,
                                        onChanged: (_) => _toggle(entry.key),
                                      ),
                                      onTap: () => _toggle(entry.key),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
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
            child: ElevatedButton.icon(
              onPressed: _saveAndShowResult,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('احسب المعدل'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
