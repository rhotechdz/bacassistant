import 'package:bacassistant/curriculum.dart';
import 'package:bacassistant/features/BAC/screens/bac_list_page.dart';
import 'package:bacassistant/features/grade_calculator/screens/grade_calculator.dart';
import 'package:bacassistant/quiz.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

Route<T> drillDown<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) =>
        SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    ),
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
