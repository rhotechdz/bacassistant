import 'package:bacassistant/screens/introduction_flow/introduction_page_1.dart';
import 'package:bacassistant/screens/introduction_flow/introduction_page_2.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBack();
          }
        },
        child: Scaffold(
          body: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 420),
              reverse: _showFirst,
              transitionBuilder: (Widget child, Animation<double> primary,
                  Animation<double> secondary) {
                return SharedAxisTransition(
                  animation: primary,
                  secondaryAnimation: secondary,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child:
                  _showFirst ? IntroductionPageOne() : IntroductionPageTwo()),
          floatingActionButton: _showFirst
              ? FloatingActionButton.extended(
                  onPressed: _toggle,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('التالي'),
                )
              : null,
        ),
      ),
    );
  }
}
