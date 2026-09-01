

import 'dart:io';

import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BacDocument {
  static const String baseUrl = 'https://bac-assistant.idrismore18.workers.dev';

  final int year;
  final String subject;
  final String field;

  String get cacheDirectoryPath => '$appStorage/bac_cache';
  String get path => '$cacheDirectoryPath/$filename';
  String get correctionPath => '$cacheDirectoryPath/$correctionFilename';

  String get filename => ['islam', 'tamazight'].contains(subject)
     ? '$subject-$year.pdf'
     : '$subject-$field-$year.pdf';

  String get correctionFilename => 'correction-$filename';

  String get remoteUrl => '$baseUrl/$year/$filename';
  String get correctionRemoteUrl => '$baseUrl/$year/$correctionFilename';

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
     subject: subjectDict[subject] ?? subject,
     field: fieldDict[field] ?? field,
   );
  }

  Future<Map<String, String>> get authHeaders async {
   final token = await FirebaseAuth.instance.currentUser?.getIdToken();
   if (token == null || token.isEmpty) {
     throw StateError('No Firebase user token available for BAC downloads.');
   }

   return {'Authorization': 'Bearer $token'};
  }

  Future<void> ensureDocumentCache() async {
   final cacheDirectory = Directory(cacheDirectoryPath);
   if (!await cacheDirectory.exists()) {
     await cacheDirectory.create(recursive: true);
   }
  }

  Future<void> downloadDocument({required bool correction}) async {
   await ensureDocumentCache();
   final targetPath = correction ? correctionPath : path;
   final url = correction ? correctionRemoteUrl : remoteUrl;

   if (File(targetPath).existsSync()) {
     return;
   }

   final dio = Dio();
   await dio.download(
     url,
     targetPath,
     options: Options(headers: await authHeaders),
     deleteOnError: false,
   );
  }

  bool exists(String filePath) => File(filePath).existsSync();
}
