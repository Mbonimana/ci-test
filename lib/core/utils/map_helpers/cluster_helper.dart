import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/data/models/organization_feature.dart';

class ClusterHelper {
  const ClusterHelper._();

  static const String sourceId = 'org-source';
  static const String clusterLayerId = 'cluster-circles';
  static const String clusterCountLayerId = 'cluster-count';

  static Future<void> applyClustering(
    MapboxMap map,
    List<OrganizationFeature> organizations, {
    String assetPath = 'assets/mock/clustered_organizations.geojson',
  }) async {
    String geoJson;

    try {
      geoJson = await rootBundle.loadString(assetPath);
    } catch (_) {
      final features = organizations
          .where((o) => o.hasValidCoordinates)
          .map(
            (o) => {
              'type': 'Feature',
              'properties': {'type': o.primaryType, 'name': o.displayName},
              'geometry': {
                'type': 'Point',
                'coordinates': [o.longitude, o.latitude],
              },
            },
          )
          .toList();

      geoJson = jsonEncode({'type': 'FeatureCollection', 'features': features});
    }

    try {
      await map.style.removeStyleLayer(clusterCountLayerId);
    } catch (_) {}

    try {
      await map.style.removeStyleLayer(clusterLayerId);
    } catch (_) {}

    try {
      await map.style.removeStyleSource(sourceId);
    } catch (_) {}

    final source = GeoJsonSource(
      id: sourceId,
      data: geoJson,
      cluster: true,
      clusterRadius: 60,
      clusterMaxZoom: 14,
    );

    await map.style.addSource(source);

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
