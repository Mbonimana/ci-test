import 'package:street_team/core/config/env_config.dart';

class Endpoints {
 //base urls
  static const String murugoBaseUrl = EnvConfig.murugoBaseUrl;
  static const String apiBaseUrl = EnvConfig.baseUrl;
  
  static const String murugoToken = '/oauth/token';
  /// Get Murugo User
  static const String thirdPartyMe = '/api/thirdparty-me';
  /// Street Team Login
  static const String ccLogin = '/api/cc-login';
}
