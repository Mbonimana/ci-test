import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:street_team/core/utils/map_helpers/cluster_helper.dart';
import 'package:street_team/core/utils/map_helpers/icon_helper.dart';
import 'package:street_team/core/utils/map_helpers/label_style_helper.dart';
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/models/organization_feature.dart';

class MapboxMapEngine implements MapEngine {
  MapboxMap? _mapboxMap;
  IconHelper? _iconHelper;
  geo.LatLng? _userLocation;

  static const String _style = MapboxStyles.MAPBOX_STREETS;

  @override
  Widget buildMap({
    required geo.LatLng userLocation,
    required List<OrganizationFeature> organizations,
  }) {
    _userLocation = userLocation;
    _iconHelper ??= IconHelper();

    return _MapboxMapView(
      style: _style,
      userLocation: userLocation,
      organizations: organizations,
      iconHelper: _iconHelper!,
      onMapCreated: (map) {
        _mapboxMap = map;
      },
    );
  }

  @override
  void goToUserLocation() {
    if (_mapboxMap == null || _userLocation == null) {
      return;
    }

    _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            _userLocation!.longitude,
            _userLocation!.latitude,
          ),
        ),
        zoom: 16,
      ),
      MapAnimationOptions(duration: 800),
    );
  }
}

class _MapboxMapView extends StatefulWidget {
  const _MapboxMapView({
    required this.style,
    required this.userLocation,
    required this.organizations,
    required this.iconHelper,
    required this.onMapCreated,
  });

  final String style;
  final geo.LatLng userLocation;
  final List<OrganizationFeature> organizations;
  final IconHelper iconHelper;
  final void Function(MapboxMap map) onMapCreated;

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
          widget.userLocation.longitude,
          widget.userLocation.latitude,
        ),
      ),
      zoom: 13,
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
      onMapCreated: (createdMap) {
        _map = createdMap;
        widget.onMapCreated(createdMap);
      },
      onStyleLoadedListener: _handleStyleLoaded,
      onCameraChangeListener: _handleCameraChanged,
    );
  }

  Future<void> _handleStyleLoaded(StyleLoadedEventData data) async {
    _styleLoaded = true;

    if (_map == null) {
      return;
    }

    await LabelStyleHelper.applyMinimalLabels(_map!);

    try {
      await _map!.setBounds(
        CameraBoundsOptions(
          minZoom: 1.0,
          maxZoom: 22.0,
          minPitch: 0.0,
          maxPitch: 85.0,
        ),
      );
    } catch (_) {}

    await ClusterHelper.applyClustering(_map!, widget.organizations);

    _annotationManager ??= await _map!.annotations
        .createPointAnnotationManager();
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
        if (!organization.hasValidCoordinates) {
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
                organization.longitude,
                organization.latitude,
              ),
            ),
            image: image,
            iconSize: 1.0,
          ),
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }
}
