

import 'dart:convert';
import 'package:bacassistant/utils/initializer.dart';

class GPAModel {
  final Map<String, dynamic> scoreMap = {};

  double calculateAverage() {
    double totalWeightedPoints = 0;
    int totalFactors = 0;

    for (var value in scoreMap.values) {
      if (value is Map) {
        totalWeightedPoints += (value['points'] as double) * (value['factor'] as int);
        totalFactors += value['factor'] as int;
      }
    }
    return totalWeightedPoints / totalFactors;
  }

  void saveResult() {
    if (prefs.getString('GPA_records') == null) {
      prefs.setString('GPA_records', jsonEncode({
        DateTime.now().millisecondsSinceEpoch.toString(): scoreMap
      }));
    } else {
      final Map gpaRecords = jsonDecode(prefs.getString('GPA_records')!);
      prefs.setString(
        'GPA_records',
        jsonEncode({
          ...gpaRecords,
          DateTime.now().millisecondsSinceEpoch.toString(): scoreMap
        })
      );
    }
  }
}