import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/data/models/organization_model.dart';

class ClusterHelper {
  const ClusterHelper._();

  static const String sourceId = 'org-source';
  static const String clusterLayerId = 'cluster-circles';
  static const String clusterCountLayerId = 'cluster-count';

  static Future<void> applyClustering(
    MapboxMap map,
    List<OrganizationModel> organizations, {
    String assetPath = 'assets/mock/clustered_organizations.geojson',
  }) async {
    String geoJson;

    try {
      geoJson = await rootBundle.loadString(assetPath);
    } catch (_) {
      final features = organizations
          .where(
            (o) => o.location.hasValidCoordinates,
          ) // Accessing coordinates via Location
          .map(
            (o) => {
              'type': 'Feature',
              'properties': {
                'type': o.primaryType,
                'name': o
                    .organizationName,
              },
              'geometry': {
                'type': 'Point',
                'coordinates': [
                  o.location.longitude, // Nested Location model
                  o.location.latitude, // Nested Location model
                ],
              },
            },
          )
          .toList();

      geoJson = jsonEncode({'type': 'FeatureCollection', 'features': features});
    }

    // Clean up existing layers/sources before adding new ones
    try {
      await map.style.removeStyleLayer(clusterCountLayerId);
    } catch (_) {}

    try {
      await map.style.removeStyleLayer(clusterLayerId);
    } catch (_) {}

    try {
      await map.style.removeStyleSource(sourceId);
    } catch (_) {}

    // Create GeoJson Source with clustering enabled
    final source = GeoJsonSource(
      id: sourceId,
      data: geoJson,
      cluster: true,
      clusterRadius: 60,
      clusterMaxZoom: 14,
    );

    await map.style.addSource(source);

    // Create the cluster circles layer
    final clusterLayer = CircleLayer(
      id: clusterLayerId,
      sourceId: sourceId,
      filter: ['has', 'point_count'],
      circleColor: AppColors.mapMarkerBackground.value,
      circleRadiusExpression: [
        'interpolate',
        ['linear'],
        ['get', 'point_count'],
        1,
        18,
        50,
        28,
        200,
        40,
      ],
      circleStrokeColor: 0xFFFFFFFF,
      circleStrokeWidth: 2,
    );

    await map.style.addLayer(clusterLayer);

    // Create the cluster count text layer
    final countLayer = SymbolLayer(
      id: clusterCountLayerId,
      sourceId: sourceId,
      filter: ['has', 'point_count'],
      textFieldExpression: ['get', 'point_count'],
      textSize: 16,
      textColor: 0xFFFFFFFF,
      textAllowOverlap: true,
      textAnchor: TextAnchor.CENTER,
    );

    await map.style.addLayer(countLayer);
  }
}
