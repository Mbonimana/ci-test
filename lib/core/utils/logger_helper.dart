import 'dart:convert';

import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _line =
      '────────────────────────────────────────────────────────';

  static const int _chunkSize = 800;
  static const int _maxLogLength = 4000;

  static void _printLong(String text) {
    if (text.length > _maxLogLength) {
      text = '${text.substring(0, _maxLogLength)}\n...[TRUNCATED]';
    }

    for (int i = 0; i < text.length; i += _chunkSize) {
      final end = (i + _chunkSize < text.length) ? i + _chunkSize : text.length;

      debugPrint(text.substring(i, end));
    }
  }

  static String _pretty(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  static void request({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    debugPrint('');
    debugPrint('┌$_line');
    debugPrint('│ 🚀 REQUEST');
    debugPrint('├$_line');
    debugPrint('│ $method $url');

    if (headers != null && headers.isNotEmpty) {
      debugPrint('│');
      debugPrint('│ Headers:');

      headers.forEach((key, value) {
        final hiddenValue = key.toLowerCase() == 'authorization'
            ? 'Bearer ********'
            : value.toString();

        debugPrint('│ $key: $hiddenValue');
      });
    }

    debugPrint('│');
    debugPrint('│ Body:');

    if (body != null) {
      _printLong(_pretty(body));
    } else {
      debugPrint('│ null');
    }

    debugPrint('└$_line');
  }

  static void response({
    required int statusCode,
    required String url,
    dynamic data,
  }) {
    debugPrint('');
    debugPrint('┌$_line');
    debugPrint('│ ✅ RESPONSE [$statusCode]');
    debugPrint('├$_line');
    debugPrint('│ URL: $url');

    if (data is Map && data['data'] is List) {
      debugPrint('│ Items: ${(data['data'] as List).length}');
    }

    debugPrint('│');
    debugPrint('│ Data:');

    _printLong(_pretty(data));

    debugPrint('└$_line');
  }

  static void error({int? statusCode, required String url, dynamic error}) {
    debugPrint('');
    debugPrint('┌$_line');
    debugPrint('│ ❌ ERROR [${statusCode ?? 'UNKNOWN'}]');
    debugPrint('├$_line');
    debugPrint('│ URL: $url');
    debugPrint('│');
    debugPrint('│ Message:');

    _printLong(_pretty(error));

    debugPrint('└$_line');
  }
}
