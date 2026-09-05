import 'package:bacassistant/services/google_sign_in/auth_service.dart';
import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
import 'package:bacassistant/themes/griadient_color.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroductionPageTwo extends StatefulWidget {
  const IntroductionPageTwo({super.key});

  @override
  State<IntroductionPageTwo> createState() => _IntroductionPageTwoState();
}

class _IntroductionPageTwoState extends State<IntroductionPageTwo> {
  final fieldList = fieldDict.keys.toList();
  Color color1 = GradientColors.color1; // top-left
  Color color2 = GradientColors.color2; // bottom-right

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                /* gradient: RadialGradient(
                center: Alignment(0.7, 0.5), // near the top left
                radius: 0.6, // smaller = tighter circle, larger = spread out
                focalRadius: 0.5,
                colors: [
                  GradientColors.color1.withAlpha(40), // top-left
                  GradientColors.color2.withAlpha(50), // outer color
                ],
              ), */
                ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.6), // near the top left
                radius: 0.6, // smaller = tighter circle, larger = spread out
                focalRadius: 0.5,
                colors: [
                  GradientColors.color1.withAlpha(60), // top-left
                  GradientColors.color2.withAlpha(50), // outer color
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 50),
                  Text(
                    "سَجِّلْ دُخُولَكَ",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "ابدأ رحلتك نحو النجاح في الباكالوريا",
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Lottie.asset(
                    'assets/animations/intro_illustration.json',
                    height: 350,
                  ),
                  Tappable(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      try {
                        await AuthService().signInWithGoogle();
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Google login failed: $error')),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.72,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/android_light_rd_na@4x.png',
                            height: 32,
                            width: 32,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'تسجيل الدخول',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
