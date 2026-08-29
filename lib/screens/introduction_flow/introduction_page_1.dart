

import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
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
                  GradientColors.color1.withAlpha(60), // top-left
                  GradientColors.color2.withAlpha(50), // outer color
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("اِخْتَرْ شُعْبَتَكَ",
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
                  child: Text('حدد الشعبـة الخاصة بك لتحصل على محتوى موجه ومناسب لك',
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
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: List.generate(fieldList.length, (index) {
                      return PressAnimationButton(
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              fieldList[index],
                              textDirection: TextDirection.ltr,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                              strutStyle: const StrutStyle(
                                forceStrutHeight: true,
                                height: 1.2,
                                leading: 0,
                              ),
                              style: TextStyle(
                                letterSpacing: 0.6,
                                color: prefs.getString("chosenField")! == fieldList[index]
                                ? Colors.black
                                : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Icon(
                                prefs.getString("chosenField")! == fieldList[index]
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            prefs.setString("chosenField", fieldList[index]);
                          });
                        },
                        style: TextButton.styleFrom(
                          alignment: Alignment.centerRight,
                          elevation: 0,
                          minimumSize: Size(double.infinity, 65),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                          backgroundColor: prefs.getString("chosenField")! == fieldList[index]
                          ? Colors.transparent
                          : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: index == 0 ? const Radius.circular(9) : Radius.zero,
                              bottom: index == fieldList.length - 1
                                ? const Radius.circular(9)
                                : Radius.zero,
                            )
                          ),
                        ),
                      );
                    })
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