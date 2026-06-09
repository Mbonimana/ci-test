import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class NetworkErrorHandler {
  static const String noInternetMessage = 'No internet connection. Try again.';
  static const String timeoutMessage =
      'Request timed out. Check your internet and try again.';
  static const String genericMessage =
      'Something went wrong. Please try again.';

  static String toUserMessage(dynamic error) {
    if (error is DioException) {
      return _fromDio(error);
    }

    if (error is PlatformException) {
      return _fromPlatform(error);
    }

    if (error is SocketException) {
      return noInternetMessage;
    }

    if (error is TimeoutException) {
      return timeoutMessage;
    }

    if (error is Exception) {
      final raw = error.toString().replaceFirst('Exception: ', '').trim();
      if (raw.isNotEmpty) return raw;
    }

    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }

    return genericMessage;
  }

  static String _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return timeoutMessage;
      case DioExceptionType.connectionError:
        return noInternetMessage;
      case DioExceptionType.badResponse:
        final extracted = _extractServerMessage(error.response?.data);
        if (extracted.isNotEmpty) return extracted;
        return 'Request failed (${error.response?.statusCode ?? 'unknown'}).';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again.';
      case DioExceptionType.unknown:
        if (error.error is SocketException ||
            _looksLikeConnectivityIssue(
              '${error.message ?? ''} ${error.error ?? ''}',
            )) {
          return noInternetMessage;
        }
        return genericMessage;
    }
  }

  static String _fromPlatform(PlatformException error) {
    final payload =
        '${error.code} ${error.message ?? ''} ${error.details ?? ''}'
            .toLowerCase();

    if (payload.contains('timed out') || payload.contains('timeout')) {
      return timeoutMessage;
    }

    if (_looksLikeConnectivityIssue(payload)) {
      return noInternetMessage;
    }

    return genericMessage;
  }

  static bool _looksLikeConnectivityIssue(String value) {
    final text = value.toLowerCase();
    return text.contains('io_error') ||
        text.contains('unavailable') ||
        text.contains('socket') ||
        text.contains('network') ||
        text.contains('internet') ||
        text.contains('failed host lookup') ||
        text.contains('connection refused') ||
        text.contains('dns');
  }

  static String _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message =
          data['message'] ?? data['error'] ?? data['detail'] ?? data['errors'];
      if (message == null) return '';
      if (message is List) return message.join(', ');
      if (message is Map) return message.toString();
      return message.toString().trim();
    }

    if (data is List) {
      return data.join(', ').trim();
    }

    return data?.toString().trim() ?? '';
  }
}
