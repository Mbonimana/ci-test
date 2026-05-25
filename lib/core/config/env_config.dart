class EnvConfig {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  static const bool enableLogs = bool.fromEnvironment(
    'ENABLE_LOGS',
    defaultValue: true,
  );
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  static const String mapBoxToken = String.fromEnvironment(
    'MAP_BOX_ACCESS_TOKEN',
    defaultValue: '',
  );
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );
  static const String murugoUrl = String.fromEnvironment(
    'MURUGO_URL',
    defaultValue: '',
  );
  static bool get isDevelopment => environment == 'development';
  static bool get isBeta => environment == 'beta';
  static bool get isProduction => environment == 'production';
}
