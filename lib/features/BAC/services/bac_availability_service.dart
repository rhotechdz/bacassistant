import 'dart:convert';

import 'package:bacassistant/features/BAC/models/bac_document.dart';
import 'package:bacassistant/utils/constants.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:dio/dio.dart';

class BacAvailabilityService {
  static const _cacheKeyPrefix = 'bacAvailability_';
  static const _timestampKeyPrefix = 'bacAvailabilityTimestamp_';
  static const _cacheDuration = Duration(days: 1);

  final Dio _client;

  BacAvailabilityService({Dio? client}) : _client = client ?? Dio();

  Future<List<String>> subjectsFor({
    required int year,
    required String field,
  }) async {
    final files = await filesForYear(year);
    return subjectDict.keys
        .where((subject) => subject != 'التربية البدنية')
        .where((subject) => documentIsAvailable(
              files: files,
              year: year,
              subject: subject,
              field: field,
            ))
        .cast<String>()
        .toList();
  }

  Future<Set<String>> filesForYear(int year) async {
    final cacheKey = '$_cacheKeyPrefix$year';
    final timestampKey = '$_timestampKeyPrefix$year';
    final cached = _readCache(cacheKey);
    final lastUpdated = prefs.getInt(timestampKey);
    final isFresh = lastUpdated != null &&
        DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(lastUpdated)) <
            _cacheDuration;

    if (cached != null && isFresh) {
      return cached;
    }

    try {
      final response = await _client.get('${BacDocument.baseUrl}/$year/');
      if (response.statusCode != 200) {
        throw StateError(
          'Failed to load BAC availability for $year: ${response.statusCode}',
        );
      }

      final files = parseFileNames(response.data);
      await prefs.setString(cacheKey, jsonEncode(files.toList()));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      return files;
    } catch (_) {
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Set<String>? _readCache(String key) {
    final value = prefs.getString(key);
    if (value == null) {
      return null;
    }

    final decoded = jsonDecode(value);
    if (decoded is! List) {
      throw StateError('Invalid BAC availability cache.');
    }

    return decoded.whereType<String>().toSet();
  }

  static Set<String> parseFileNames(Object? responseData) {
    if (responseData is! List) {
      throw FormatException('BAC availability response is not a list.');
    }

    return responseData
        .whereType<String>()
        .map((path) => path.split('/').last)
        .where((filename) =>
            filename.endsWith('.pdf') && !filename.startsWith('correction-'))
        .toSet();
  }

  static bool documentIsAvailable({
    required Set<String> files,
    required int year,
    required String subject,
    required String field,
  }) {
    final normalizedSubject = subjectDict[subject] ?? subject;
    final normalizedField = fieldDict[field] ?? field;
    final filename =
        normalizedSubject == 'islam' || normalizedSubject == 'tamazight'
            ? '$normalizedSubject-$year.pdf'
            : '$normalizedSubject-$normalizedField-$year.pdf';

    return files.contains(filename);
  }
}
