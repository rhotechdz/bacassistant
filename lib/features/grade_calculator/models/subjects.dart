import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';

class Subjects {
  final String field = prefs.getString('chosenField') ?? 'شعبة علوم تجريبية';
  late final Map<String, int> map;
  late Map<String, int> unified = {};

  final Map<String, List<dynamic>> optional = {
    'اللغة الأمازيغية': [2, prefs.getBool('tamazight') ?? true],
    'التربية البدنية': [1, prefs.getBool('sports') ?? true],
  };

  Subjects() {
    map = Map<String, int>.from(subjectsMap[field] as Map)
      ..remove('اللغة الأمازيغية')
      ..remove('التربية البدنية');
    unify();
  }

  int get length => map.length;
  int get totalLength => unified.length;
  List get keys => map.keys.toList();
  List get values => map.values.toList();

  void update(String key) {
    final currentState = optional[key]?[1] as bool? ?? true;
    final newState = !currentState;
    optional[key]![1] = newState;

    if (key == 'اللغة الأمازيغية') {
      prefs.setBool('tamazight', newState);
    } else if (key == 'التربية البدنية') {
      prefs.setBool('sports', newState);
    }
  }

  void unify() {
    unified = {
      ...map,
      ...{
        for (final entry in optional.entries)
          if (entry.value[1] as bool) entry.key: entry.value[0] as int,
      },
    };
  }
}
