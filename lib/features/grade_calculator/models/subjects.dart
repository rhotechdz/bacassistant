import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';

class Subjects {
  final String field = prefs.getString('chosenField')!;
  late Map<String, int> map;
  late Map<String, int> unified;
  final Map<String, List> optional = {
    "اللغة الأمازيغية": [2, true],
    "التربية البدنية": [1, true]
  };

  Subjects() {
    map = Map.of(subjectsMap[field])
      ..remove("اللغة الأمازيغية")
      ..remove("التربية البدنية");
  }

  int get length => map.length;
  int get totalLength => unified.length;
  List get keys => map.keys.toList();
  List get values => map.values.toList();

  void update(String key) => optional[key]![1] = !optional[key]![1];
  void unify() => unified = {
    ...map,
    ...{for (var e in optional.entries) if (e.value[1]) e.key: e.value[0]}
  };
}
