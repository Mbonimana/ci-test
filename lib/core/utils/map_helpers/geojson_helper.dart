// geojson_helper.dart

import 'dart:convert';

import 'package:street_team/data/models/organization_model.dart';

class GeoJsonHelper {
  const GeoJsonHelper._();

  /// It checks the nested [location] object for valid coordinates.
  static Map<String, dynamic> buildFeatureCollection(
    List<OrganizationModel> organizations,
  ) {
    return {
      'type': 'FeatureCollection',
      'features': organizations
          .where(
            (e) => e.location.hasValidCoordinates,
          ) // Updated to check nested location
          .map(
            (e) => e.toGeoJsonFeature(),
          ) // Uses the internal model logic to flatten data
          .toList(),
    };
  }

  /// Converts the list of organizations into a serialized GeoJSON string.
  static String buildGeoJson(List<OrganizationModel> organizations) {
    return jsonEncode(buildFeatureCollection(organizations));
  }
}
