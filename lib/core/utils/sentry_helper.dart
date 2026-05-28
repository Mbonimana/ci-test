import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:street_team/core/config/env_config.dart';

class SentryHelper {
  SentryHelper._();

  static bool get _isEnabled => EnvConfig.sentryDsn.isNotEmpty;

  static Future<void> captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    if (!_isEnabled) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (extras != null) {
          scope.setContexts('additional_data', extras);
        }
      },
    );
  }

  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_isEnabled) return;

    await Sentry.captureMessage(message, level: level);
  }

  static Future<void> setUser({
    required String id,
    required String username,
    String? email,
  }) async {
    if (!_isEnabled) return;

    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: id, username: username, email: email));
    });
  }

  static Future<void> clearUser() async {
    if (!_isEnabled) return;

    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}
