import 'package:street_team/core/config/env_config.dart';

class Endpoints {
  //base urls
  static const String murugoBaseUrl = EnvConfig.murugoBaseUrl;
  static const String apiBaseUrl = EnvConfig.baseUrl;
  static const String publicKey = EnvConfig.publicKey;

  static const String murugoToken = '/oauth/token';

  // Get Murugo User
  static const String thirdPartyMe = '/api/thirdparty-me';

  // Street Team Login
  static const String ccLogin = '/api/cc-login';

  //locations endpoints

  // Types and Sub types:
  static const String getLocationTypes =
      '$apiBaseUrl/api/v2/types?category=location';

  static const String getOrganizationTypes =
      '$apiBaseUrl/api/v2/types?category=organization';

  // Submit new location
  static const String submitLocation = '$apiBaseUrl/api/v2/submitted-locations';
  // Get paginated locations
  static const String getLocations =
      '$apiBaseUrl/api/v2/paginated-locations?app_key=$publicKey';
  // Search locations
  static String searchLocation = '$apiBaseUrl/api/search-location';
  // Update location
  static String updateLocation(String id) => '$apiBaseUrl/api/locations/$id';
  // Get location by ID
  static String getLocationById(String id) =>
      '$apiBaseUrl/api/v2/locations/$id?app_key=$publicKey';

  // Organizations endpoints
  static const String submitOrganization =
      '$apiBaseUrl/api/v2/add-street-team-data';
  static String updateOrganization(String id) =>
      '$apiBaseUrl/api/organizations/$id';
}
