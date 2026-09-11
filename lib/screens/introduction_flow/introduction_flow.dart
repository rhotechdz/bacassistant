import 'package:bacassistant/screens/introduction_flow/introduction_page_1.dart';
import 'package:bacassistant/screens/introduction_flow/introduction_page_2.dart';
import 'package:bacassistant/themes/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:bacassistant/utils/system_ui.dart';

class IntroductionFlow extends StatefulWidget {
  const IntroductionFlow({super.key});
  @override
  State<IntroductionFlow> createState() => _IntroductionFlowState();
}

class _IntroductionFlowState extends State<IntroductionFlow> {
  bool _showFirst = true;
  DateTime? _lastBackPress;

  void _toggle() => setState(() => _showFirst = !_showFirst);

  void _handleBack() {
    if (!_showFirst) {
      setState(() => _showFirst = true);
      return;
    }

    final now = DateTime.now();
    final isSecondPress = _lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2);
    if (isSecondPress) {
      Navigator.of(context).pop();
      return;
    }

    _lastBackPress = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'اضغط مرة أخرى للخروج',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.bgDark
        : Theme.of(context).colorScheme.surface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyleFor(
        Theme.of(context).colorScheme,
        brightness: Theme.of(context).brightness,
        barColor: backgroundColor,
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _handleBack();
            }
          },
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: ColoredBox(
              color: backgroundColor,
              child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 420),
                  reverse: _showFirst,
                  transitionBuilder: (Widget child, Animation<double> primary,
                      Animation<double> secondary) {
                    return SharedAxisTransition(
                      animation: primary,
                      secondaryAnimation: secondary,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: backgroundColor,
                      child: child,
                    );
                  },
                  child: _showFirst
                      ? const IntroductionPageOne()
                      : const IntroductionPageTwo()),
            ),
            floatingActionButton: _showFirst
                ? FloatingActionButton.extended(
                    onPressed: _toggle,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('التالي'),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
