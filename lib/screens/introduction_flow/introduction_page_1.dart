import 'package:bacassistant/themes/griadient_color.dart';
import 'package:bacassistant/themes/ui_colors.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';

class IntroductionPageOne extends StatefulWidget {
  const IntroductionPageOne({super.key});

  @override
  State<IntroductionPageOne> createState() => _IntroductionPageOneState();
}

class _IntroductionPageOneState extends State<IntroductionPageOne> {
  final fieldList = fieldDict.keys.toList();
  static const fieldIcons = {
    'شعبة علوم تجريبية': Icons.biotech_outlined,
    'شعبة آداب وفلسفة': Icons.menu_book_outlined,
    'شعبة لغات أجنبية': Icons.translate_outlined,
    'شعبة تسيير واقتصاد': Icons.business_center_outlined,
    'شعبة رياضيات': Icons.calculate_outlined,
    'شعبة تقني رياضي': Icons.engineering_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.9, 0.5),
                radius: 0.6,
                focalRadius: 0.5,
                colors: [
                  GradientColors.color1.withAlpha(30),
                  GradientColors.color2.withAlpha(20),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.8, -0.6), // near the top left
                radius: 0.6, // smaller = tighter circle, larger = spread out
                focalRadius: 0.5,
                colors: [
                  GradientColors.color1.withAlpha(60),
                  GradientColors.color2.withAlpha(50),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "اِخْتَرْ شُعْبَتَكَ",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'حدد الشعبـة الخاصة بك لتحصل على محتوى موجه ومناسب لك',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: MediaQuery.of(context).size.width * 0.78,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(fieldList.length, (index) {
                      final field = fieldList[index];
                      final isSelected =
                          field == prefs.getString('chosenField');
                      final colors = Theme.of(context).colorScheme;

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == fieldList.length - 1 ? 0 : 8,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primaryContainer
                                : colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: 0.55)
                                  : colors.outlineVariant,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  prefs.setString('chosenField', field);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      fieldIcons[field] ??
                                          Icons.school_outlined,
                                      color: isSelected
                                          ? colors.onPrimaryContainer
                                          : colors.onSurfaceVariant,
                                      size: 25,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        field,
                                        textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.right,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? colors.onPrimaryContainer
                                                  : colors.onSurface,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
