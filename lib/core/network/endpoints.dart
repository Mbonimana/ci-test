import 'package:street_team/core/config/env_config.dart';

class Endpoints {
  //base urls
  static const String murugoBaseUrl = EnvConfig.murugoUrl;
  static const String apiBaseUrl = EnvConfig.baseUrl;

  // Auth Endpoints
  static const String murugoToken = "$murugoBaseUrl/oauth/token";
  static const String murugoMe = "$murugoBaseUrl/api/thirdparty-me";
  static const String streetTeamLogin = "$apiBaseUrl/api/cc-login";
}