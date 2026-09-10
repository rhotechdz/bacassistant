import 'package:bacassistant/services/google_sign_in/auth_service.dart';
import 'package:bacassistant/screens/introduction_flow/press_animation_button.dart';
import 'package:bacassistant/themes/ui_colors.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class IntroductionPageTwo extends StatefulWidget {
  const IntroductionPageTwo({super.key});

  @override
  State<IntroductionPageTwo> createState() => _IntroductionPageTwoState();
}

class _IntroductionPageTwoState extends State<IntroductionPageTwo> {
  final fieldList = fieldDict.keys.toList();
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width * 0.72;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.bgDark
        : colors.surface;
    final buttonColor = isDark ? AppColorsDark.bg : colors.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.6), // near the top left
                  radius: 0.6, // smaller = tighter circle, larger = spread out
                  focalRadius: 0.5,
                  colors: [
                    colors.primary.withAlpha(24),
                    colors.secondary.withAlpha(16),
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
                        color: colors.onSurface,
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
                          color: colors.onSurfaceVariant,
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Lottie.asset(
                      'assets/animations/intro_illustration.json',
                      height: 350,
                    ),
                    _isSigningIn
                        ? SizedBox(
                            width: buttonWidth,
                            height: 60,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Tappable(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () async {
                              setState(() => _isSigningIn = true);
                              try {
                                await AuthService().signInWithGoogle();
                              } on GoogleSignInException catch (error) {
                                if (error.code !=
                                        GoogleSignInExceptionCode.canceled &&
                                    context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Google login failed: $error'),
                                    ),
                                  );
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Google login failed: $error'),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isSigningIn = false);
                                }
                              }
                            },
                            child: Container(
                              width: buttonWidth,
                              height: 60,
                              decoration: BoxDecoration(
                                color: buttonColor,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
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
      ),
    );
  }
}
