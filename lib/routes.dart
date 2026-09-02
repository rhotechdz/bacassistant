import 'package:bacassistant/curriculum.dart';
import 'package:bacassistant/features/BAC/screens/bac_list_page.dart';
import 'package:bacassistant/features/grade_calculator/screens/grade_calculator.dart';
import 'package:bacassistant/quiz.dart';
import 'package:flutter/material.dart';

Route<T> drillDown<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incomingOffset = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      final outgoingOffset = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.2, 0),
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return SlideTransition(
        position: animation.drive(incomingOffset),
        child: SlideTransition(
          position: secondaryAnimation.drive(outgoingOffset),
          child: child,
        ),
      );
    },
  );
}

const List<Map> pages = [
  {"title": "بكالوريا سابقة", "icon": "graduate.png", "route": BacPage()},
  {"title": "المقرر الدراسي", "icon": "book.png", "route": CurriculumPage()},
  {"title": "إختبار الحفظ", "icon": "idea.png", "route": QuizPage()},
  {
    "title": "حساب المعدل",
    "icon": "calculator.png",
    "route": GradeCalculatorPage()
  }
];
