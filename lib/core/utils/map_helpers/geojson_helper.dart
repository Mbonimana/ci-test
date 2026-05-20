// geojson_helper.dart

import 'dart:convert';

import 'package:street_team/data/models/organization_model.dart';

class GeoJsonHelper {
  const GeoJsonHelper._();

  // feature collection

  static Map<String, dynamic> buildFeatureCollection(
    List<OrganizationModel> organizations,
  ) {
    return {
      'type': 'FeatureCollection',
      'features': organizations
          .where((e) => e.hasValidCoordinates)
          .map((e) => e.toGeoJsonFeature())
          .toList(),
    };
  }

  // geojson string

  static String buildGeoJson(
    List<OrganizationModel> organizations,
  ) {
    return jsonEncode(
      buildFeatureCollection(organizations),
    );
  }
}