import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/utils/map_helpers/camera_contols.dart';
import 'package:street_team/core/utils/map_helpers/cluster_helper.dart';
import 'package:street_team/core/utils/map_helpers/icon_helper.dart';
import 'package:street_team/core/utils/map_helpers/label_style_helper.dart';
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/models/organization_model.dart';

class MapboxMapEngine implements MapEngine {
  final MapCameraController cameraController = MapCameraController();

  IconHelper? _iconHelper;

  static const String _style = MapboxStyles.MAPBOX_STREETS;

  @override
  Widget buildMap({
    required geo.LatLng userLocation,
    required List<OrganizationModel> organizations,
  }) {
    _iconHelper ??= IconHelper();

    cameraController.setUserLocation(userLocation);

    return _MapboxMapView(
      style: _style,
      organizations: organizations,
      iconHelper: _iconHelper!,
      cameraController: cameraController,
    );
  }

  @override
  void goToUserLocation() {
    cameraController.goToUserLocation();
  }

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
    required this.organizations,
    required this.iconHelper,
    required this.cameraController,
  });

  final String style;
  final List<OrganizationModel> organizations;
  final IconHelper iconHelper;
  final MapCameraController cameraController;

  @override
  State<_MapboxMapView> createState() => _MapboxMapViewState();
}

class _MapboxMapViewState extends State<_MapboxMapView> {
  MapboxMap? _map;
  PointAnnotationManager? _annotationManager;
  bool _styleLoaded = false;
  bool _showLabels = true;
  bool _isRefreshing = false;

  static const double _labelZoomThreshold = 13;
  static const double _clusterBreakZoom = 14;

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

    if (oldWidget.organizations != widget.organizations && _styleLoaded) {
      _refreshAnnotations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey('mapbox-map-widget'),
      styleUri: widget.style,
      textureView: true,
      viewport: _viewportState,
      onMapCreated: (createdMap) async {
        _map = createdMap;

        widget.cameraController.attachMap(createdMap);
        //Keyboard dismissal on map tap
        final tapInteraction = TapInteraction.onMap((context) {
          FocusManager.instance.primaryFocus?.unfocus();
        });

        createdMap.addInteraction(tapInteraction);
      },

      onStyleLoadedListener: _handleStyleLoaded,
      onCameraChangeListener: _handleCameraChanged,
    );
  }

  Future<void> _handleStyleLoaded(StyleLoadedEventData data) async {
    _styleLoaded = true;

    if (_map == null) return;

    await _map!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    await LabelStyleHelper.applyMinimalLabels(_map!);

    try {
      await _map!.setBounds(
        CameraBoundsOptions(minZoom: 1, maxZoom: 22, minPitch: 0, maxPitch: 85),
      );
    } catch (_) {}

    // ClusterHelper already updated to handle nested location
    await ClusterHelper.applyClustering(_map!, widget.organizations);

    _annotationManager ??= await _map!.annotations
        .createPointAnnotationManager();

    await _refreshAnnotations();
  }

  Future<void> _handleCameraChanged(CameraChangedEventData data) async {
    final zoom = data.cameraState.zoom;
    final shouldShowLabels = zoom >= _labelZoomThreshold;

    if (shouldShowLabels != _showLabels) {
      if (mounted) {
        setState(() {
          _showLabels = shouldShowLabels;
        });
      }
    }

    if (zoom >= _clusterBreakZoom) {
      await _refreshAnnotations();
    } else {
      await _annotationManager?.deleteAll();
    }
  }

  Future<void> _refreshAnnotations() async {
    if (_annotationManager == null || _isRefreshing) {
      return;
    }

    _isRefreshing = true;

    try {
      await _annotationManager!.deleteAll();

      for (final organization in widget.organizations) {
        // Access coordinate validation through nested location
        if (!organization.location.hasValidCoordinates) {
          continue;
        }

        final Uint8List image = await widget.iconHelper.buildMarkerBytes(
          organization,
          showLabel: _showLabels,
        );

        await _annotationManager!.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                //  Access coordinates via nested location
                organization.location.longitude,
                organization.location.latitude,
              ),
            ),
            image: image,
            iconSize: 1,
          ),
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }
}
