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

  void _toggle() => setState(() => _showFirst = !_showFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 420),
          reverse: _showFirst, // optional: flips direction when going back
          transitionBuilder: (Widget child, Animation<double> primary,
              Animation<double> secondary) {
            return SharedAxisTransition(
              animation: primary,
              secondaryAnimation: secondary,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
          child: _showFirst ? IntroductionPageOne() : IntroductionPageTwo()),
      floatingActionButton: _showFirst
          ? FloatingActionButton.extended(
              onPressed: _toggle,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('التالي'),
            )
          : null,
    );
  }
}
