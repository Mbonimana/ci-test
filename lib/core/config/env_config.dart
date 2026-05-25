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
  static const String murugoBaseUrl = String.fromEnvironment(
    'MURUGO_BASE_URL',
    defaultValue: '',
  );

  static const String murugoPasswordResetUrl = '$murugoBaseUrl/password/reset';

  static const String appKey = String.fromEnvironment(
    'APP_KEY',
    defaultValue: '',
  );
  static const String streetTeamClientId = String.fromEnvironment(
    'STREET_TEAM_CLIENT_ID',
    defaultValue: '',
  );
  static const String streetTeamClientSecret = String.fromEnvironment(
    'STREET_TEAM_CLIENT_SECRET',
    defaultValue: '',
  );
  static const String murugoClientId = String.fromEnvironment(
    'MURUGO_CLIENT_ID',
    defaultValue: '',
  );
  static const String murugoClientSecret = String.fromEnvironment(
    'MURUGO_CLIENT_SECRET',
    defaultValue: '',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isBeta => environment == 'beta';
  static bool get isProduction => environment == 'production';
}
