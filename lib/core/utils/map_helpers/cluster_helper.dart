import 'dart:convert';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/utils/map_helpers/icon_helper.dart';
import 'package:street_team/data/models/location_response.dart';

class ClusterHelper {
  static const sourceId = "locations-source";
  static const clusterLayerId = "clusters-circle-layer";
  static const clusterCountId = "cluster-count-layer";
  static const unclusteredLayerId = "unclustered-points-layer";

  static Future<void> setup(
    MapboxMap map,
    List<LocationResponse> locations,
    IconHelper iconHelper,
  ) async {
    final valid = locations.where((e) => e.hasValidCoordinates).toList();

    final geoJson = {
      "type": "FeatureCollection",
      "features": valid.map((loc) {
        return {
          "type": "Feature",
          "properties": {
            "id": loc.id,
            "name": loc.mapLabel,
            "type": LocationTypeResolver.resolve(loc.primaryTypeName),
          },
          "geometry": {
            "type": "Point",
            "coordinates": [loc.longitude, loc.latitude],
          },
        };
      }).toList(),
    };

    await _remove(map);

    await map.style.addSource(
      GeoJsonSource(
        id: sourceId,
        data: jsonEncode(geoJson),
        cluster: true,
        clusterRadius: 80,
        clusterMaxZoom: 16,
      ),
    );

    // Cluster Circles
    await map.style.addLayer(
      CircleLayer(
        id: clusterLayerId,
        sourceId: sourceId,
        filter: ['has', 'point_count'],
        circleColor: 0xFF294057,
        circleRadiusExpression: [
          'step',
          ['get', 'point_count'],
          20,
          10,
          25,
          50,
          30,
        ],
        circleStrokeWidth: 2,
        circleStrokeColor: 0xFFFFFFFF,
      ),
    );

    //  Cluster Numbers
    await map.style.addLayer(
      SymbolLayer(
        id: clusterCountId,
        sourceId: sourceId,
        filter: ['has', 'point_count'],
        textFieldExpression: ['get', 'point_count'],
        textSize: 12,
        textColor: 0xFFFFFFFF,
        textIgnorePlacement: true,
        textAllowOverlap: true,
      ),
    );

    await map.style.addLayer(
      SymbolLayer(
        id: unclusteredLayerId,
        sourceId: sourceId,
        filter: [
          '!',
          ['has', 'point_count'],
        ],
        iconImageExpression: ['get', 'type'],
        iconSize: 0.4,

        textFieldExpression: ['get', 'name'],
        textSize: 11,
        textAnchor: TextAnchor.TOP,
        textOffset: [0, 2.5],
        textColor: 0xFF1E293B,
        iconAllowOverlap: false,
        textAllowOverlap: false,
        iconIgnorePlacement: false,
      ),
    );
  }

  static Future<void> _remove(MapboxMap map) async {
    for (final id in [clusterLayerId, clusterCountId, unclusteredLayerId]) {
      try {
        if (await map.style.styleLayerExists(id)) {
          await map.style.removeStyleLayer(id);
        }
      } catch (_) {}
    }
    try {
      if (await map.style.styleSourceExists(sourceId)) {
        await map.style.removeStyleSource(sourceId);
      }
    } catch (_) {}
  }
}
