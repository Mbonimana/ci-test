import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/utils/map_helpers/camera_contols.dart';
import 'package:street_team/core/utils/map_helpers/cluster_helper.dart';
import 'package:street_team/core/utils/map_helpers/icon_helper.dart';
import 'package:street_team/core/utils/map_helpers/label_style_helper.dart';
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/models/location_response.dart';

class MapboxMapEngine implements MapEngine {
  final MapCameraController cameraController = MapCameraController();
  IconHelper? _iconHelper;
  static const String _style = MapboxStyles.MAPBOX_STREETS;

  @override
  Widget buildMap({
    required geo.LatLng userLocation,
    required List<LocationResponse> locations,
  }) {
    _iconHelper ??= IconHelper();
    cameraController.setUserLocation(userLocation);

    return _MapboxMapView(
      style: _style,
      locations: locations,
      iconHelper: _iconHelper!,
      cameraController: cameraController,
    );
  }

  @override
  void goToUserLocation() => cameraController.goToUserLocation();

  @override
  void goToCoordinates({
    required double latitude,
    required double longitude,
    double? zoom = 16,
  }) {
    cameraController.flyTo(latitude: latitude, longitude: longitude);
  }

  @override
  void setInitialCamera({
    required double latitude,
    required double longitude,
    double? zoom = 13,
  }) {
    cameraController.setInitialCamera(latitude: latitude, longitude: longitude);
  }
}

class _MapboxMapView extends StatefulWidget {
  const _MapboxMapView({
    required this.style,
    required this.locations,
    required this.iconHelper,
    required this.cameraController,
  });

  final String style;
  final List<LocationResponse> locations;
  final IconHelper iconHelper;
  final MapCameraController cameraController;

  @override
  State<_MapboxMapView> createState() => _MapboxMapViewState();
}

class _MapboxMapViewState extends State<_MapboxMapView> {
  MapboxMap? _map;
  bool _styleLoaded = false;
  late final CameraViewportState _viewportState;

  @override
  void initState() {
    super.initState();
    _viewportState = CameraViewportState(
      center: Point(
        coordinates: Position(
          widget.cameraController.initialLongitude,
          widget.cameraController.initialLatitude,
        ),
      ),
      zoom: widget.cameraController.initialZoom,
    );
  }

  @override
  void didUpdateWidget(covariant _MapboxMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If locations change, update the source
    if (oldWidget.locations != widget.locations &&
        _styleLoaded &&
        _map != null) {
      ClusterHelper.setup(_map!, widget.locations, widget.iconHelper);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('mapbox-map-widget'),
      styleUri: widget.style,
      textureView: true,
      viewport: _viewportState,
      onMapCreated: (createdMap) {
        _map = createdMap;
        widget.cameraController.attachMap(createdMap);
      },
      onStyleLoadedListener: _handleStyleLoaded,
    );
  }

  Future<void> _handleStyleLoaded(StyleLoadedEventData data) async {
    _styleLoaded = true;
    if (_map == null) return;

    await LabelStyleHelper.applyMinimalLabels(_map!);
    await _map!.location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );
    await _loadIconsIntoMapStyle();
    await ClusterHelper.setup(_map!, widget.locations, widget.iconHelper);
  }
  Future<void> _loadIconsIntoMapStyle() async {
    final types = IconHelper.typeIcons.keys.toList();
    for (final typeKey in types) {
      final Uint8List bytes = await widget.iconHelper.getMarkerImageOnly(
        typeKey,
      );
      await _map!.style.addStyleImage(
        typeKey,
        1.0,
        MbxImage(width: 100, height: 100, data: bytes),
        false,
        [],
        [],
        null,
      );
    }
  }
}
