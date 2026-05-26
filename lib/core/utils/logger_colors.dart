import 'package:flutter/foundation.dart';

class LogColor {
  static const reset = '\x1B[0m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const red = '\x1B[31m';
  static const blue = '\x1B[34m';
  static const cyan = '\x1B[36m';
}

class PrettyDioLogger {
  static void _printBlock(String color, String title, String body) {
    final border = "--" * 100;

    for (final line in body.split('\n')) {
      debugPrint("$color║ $line$LogColor.reset");
    }

    debugPrint("$color╚$border$LogColor.reset");
  }

  static void request(String method, String url, Map headers, dynamic body) {
    _printBlock(
      LogColor.blue,
      "REQUEST ➜ $method $url",
      "HEADERS:\n$headers\n\nBODY:\n$body",
    );
  }

  static void success(int status, String url, dynamic data) {
    _printBlock(LogColor.green, "SUCCESS ➜ $status $url", "RESPONSE:\n$data");
  }

  static void error(int? status, String url, dynamic data) {
    _printBlock(LogColor.red, "ERROR ➜ $status $url", "RESPONSE:\n$data");
  }
}
