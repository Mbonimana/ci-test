import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/data/map_engine/map_engine.dart';

class MapboxMapEngine implements MapEngine {
  MapboxMap? _mapboxMap;

  static const String _style = MapboxStyles.MAPBOX_STREETS;

  @override
  Widget buildMap({required geo.LatLng userLocation}) {
    return _MapboxMapView(
      style: _style,
      userLocation: userLocation,
      onMapCreated: (map) {
        _mapboxMap = map;
      },
    );
  }

  @override
  void goToUserLocation() {
    if (_mapboxMap == null) return;

    _mapboxMap!.flyTo(
      CameraOptions(zoom: 16),
      MapAnimationOptions(duration: 800),
    );
  }
}

class _MapboxMapView extends StatefulWidget {
  final String style;
  final geo.LatLng userLocation;
  final void Function(MapboxMap map) onMapCreated;

  const _MapboxMapView({
    required this.style,
    required this.userLocation,
    required this.onMapCreated,
  });

  @override
  State<_MapboxMapView> createState() => _MapboxMapViewState();
}

class _MapboxMapViewState extends State<_MapboxMapView> {
  MapboxMap? map;

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: widget.style,
      mapOptions: MapOptions(pixelRatio: 2.6),
    
      onMapCreated: (map) async {
        map = map;
        widget.onMapCreated(map);

        await _applyMinimalLabels(map);

        await map.setCamera(
          CameraOptions(
            center: Point(
              coordinates: Position(
                widget.userLocation.longitude,
                widget.userLocation.latitude,
              ),
            ),
            zoom: 13,
          ),
        );
      },
    );
  }

  // keep only roads + zones, remove Pois
  Future<void> _applyMinimalLabels(MapboxMap map) async {
    final style = map.style;
    await Future.delayed(const Duration(milliseconds: 300));
    await _hide(style, "poi-label");
    await _hide(style, "poi-labels");
    await _hide(style, "poi");
    await _show(style, "road-label");
    await _show(style, "settlement-label");
    await _hide(style, "place-label");
    await _show(style, "state-label");
    await _hide(style, "road-number-shield");
  }

  Future<void> _hide(dynamic style, String layerId) async {
    try {
      await style.setStyleLayerProperty(layerId, "visibility", "none");
    } catch (_) {}
  }

  Future<void> _show(dynamic style, String layerId) async {
    try {
      await style.setStyleLayerProperty(layerId, "visibility", "visible");
    } catch (_) {}
  }
}
