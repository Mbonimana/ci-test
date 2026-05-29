import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LabelStyleHelper {
  const LabelStyleHelper._();

  static Future<void> applyMinimalLabels(MapboxMap map) async {
    const hiddenLayers = [
      'poi-label',
      'poi',
      'poi-labels',
      'transit-label',
      'airport-label',
      'natural-label',
      'natural-point-label',
      'water-label',
      'place-label',
      'settlement-label',
      'country-label',
      'state-label',
      'landmark-label',
      'road-label',
      'building-number-label',
      'point-label',
    ];

    for (final layerId in hiddenLayers) {
      try {
        await map.style.setStyleLayerProperty(layerId, 'visibility', 'none');
      } catch (_) {}
    }

    const visibleLayers = [
      'road-label',
      'road-number-shield',
      'road-shield',
      'motorway-label',
      'street-label',
      'settlement-subdivision-label',
      'settlement-minor-label',
    ];

    for (final layerId in visibleLayers) {
      try {
        await map.style.setStyleLayerProperty(layerId, 'visibility', 'visible');
      } catch (_) {}
    }
  }
}
