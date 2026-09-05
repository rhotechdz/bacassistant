import 'dart:convert';

import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CurriculumCache {
  static const files = [
    'curriculum_math.json',
    'curriculum_physics.json',
    'curriculum_history_geography.json',
  ];

  static const _cacheKeyPrefix = 'curriculum_';
  static const _timestampKeyPrefix = 'curriculumTimestamp_';
  static const _cacheDuration = Duration(days: 1);

  final Dio _client;

  CurriculumCache({Dio? client}) : _client = client ?? Dio();

  Future<void> loadAll() async {
    await Future.wait(files.map((filename) async {
      try {
        await loadFile(filename);
      } on Object catch (error) {
        debugPrint('Unable to refresh $filename: $error');
      }
    }));
  }

  Future<String> loadFile(String filename) async {
    final cacheKey = '$_cacheKeyPrefix$filename';
    final timestampKey = '$_timestampKeyPrefix$filename';
    final cached = prefs.getString(cacheKey);
    final timestamp = prefs.getInt(timestampKey);
    final isFresh = timestamp != null &&
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(timestamp)) <
            _cacheDuration;

    if (cached != null && isFresh) {
      return cached;
    }

    try {
      final response = await _client.get(
        '${BacDocument.baseUrl}/curriculum/$filename',
      );
      if (response.statusCode != 200) {
        throw StateError(
          'Failed to load curriculum file $filename: ${response.statusCode}',
        );
      }

      final content = response.data is String
          ? response.data as String
          : jsonEncode(response.data);
      jsonDecode(content);
      await prefs.setString(cacheKey, content);
      await prefs.setInt(
        timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      return content;
    } catch (_) {
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  String? readCachedFile(String filename) {
    return prefs.getString('$_cacheKeyPrefix$filename');
  }
}
