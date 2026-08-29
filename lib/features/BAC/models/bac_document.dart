

import 'dart:io';

import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';

class BacDocument {
  int year;
  String subject;
  String field;

  String get path => '$appStorage/$filename';
  String get correctionPath => '$appStorage/$correctionFilename';

  String get filename => ['islam', 'tamazight'].contains(subject)
   ? '$subject-$year.pdf'
   : '$subject-$field-$year.pdf';

  String get correctionFilename => 'correction-$filename';

  BacDocument._({
    required this.year,
    required this.subject,
    required this.field,
  });

  factory BacDocument({
    required int year,
    required String subject,
    required String field,
  }) {
    debugPrint('Creating BacDocument for $subject, $field, $year');
    return BacDocument._(
      year: year,
      subject: subjectDict[subject],
      field: fieldDict[field],
    );
  }

  bool exists(String path) => File(path).existsSync();
}
