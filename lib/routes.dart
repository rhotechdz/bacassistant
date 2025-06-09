
import 'package:bacassistant/bac.dart';
import 'package:bacassistant/calculate.dart';
import 'package:bacassistant/curriculum.dart';
import 'package:bacassistant/quiz.dart';

const List<Map> pages = [
  {
    "title": "بكالوريا سابقة",
    "subtitle": "جميع البكالوريا السابقة",
    "icon": "graduate.png",
    "route": BacPage()
  },
  {
    "title": "المقرر الدراسي",
    "subtitle": "جميع الدروس الممنهجة",
    "icon": "book.png",
    "route": CurriculumPage()
  },
  {
    "title": "إختبار الحفظ",
    "subtitle": "إختبر قدراتك",
    "icon": "idea.png",
    "route": QuizPage()
  },
  {
    "title": "حساب المعدل",
    "subtitle": "حساب المعدل",
    "icon": "calculator.png",
    "route": CalculatePage()
  }
];