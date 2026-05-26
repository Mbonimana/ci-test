import 'dart:convert';

import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _line =
      '────────────────────────────────────────────────────────';

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
      const encoder = JsonEncoder.withIndent('  ');
      debugPrint(encoder.convert(body));
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
    debugPrint('│');
    debugPrint('│ Data:');

    const encoder = JsonEncoder.withIndent('  ');

    try {
      debugPrint(encoder.convert(data));
    } catch (_) {
      debugPrint(data.toString());
    }

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

    try {
      const encoder = JsonEncoder.withIndent('  ');
      debugPrint(encoder.convert(error));
    } catch (_) {
      debugPrint(error.toString());
    }

    debugPrint('└$_line');
  }
}
