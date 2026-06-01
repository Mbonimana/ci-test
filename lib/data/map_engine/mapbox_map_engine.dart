import 'dart:async';
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
import 'package:street_team/presentation/ui/widgets/shared/location_details_sheet.dart';

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
  void goToUserLocation({double? zoom = 12}) => cameraController.goToUserLocation();

  @override
  void goToCoordinates({
    required double latitude,
    required double longitude,
    double? zoom = 9,
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

  void _showDetailsSheet(LocationResponse location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationDetailsSheet(location: location),
    );
  }

  Future<void> _zoomIntoCluster() async {
    if (_map == null) return;

    final cameraState = await _map!.getCameraState();
    await _map!.flyTo(
      CameraOptions(center: cameraState.center, zoom: cameraState.zoom + 2),
      null,
    );
  }

  Future<void> _processMapTap(ScreenCoordinate coordinate) async {
    if (_map == null) return;

    final features = await _map!.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(coordinate),
      RenderedQueryOptions(
        layerIds: [ClusterHelper.unclusteredLayerId],
        filter: null,
      ),
    );

    if (features.isNotEmpty) {
      final queriedFeature = features.first?.queriedFeature;
      if (queriedFeature != null) {
        final properties = queriedFeature.feature['properties'] as Map?;
        final locationId = properties?['id']?.toString();

        if (locationId != null) {
          try {
            final tappedLocation = widget.locations.firstWhere(
              (location) => location.id.toString() == locationId,
            );
            _showDetailsSheet(tappedLocation);
            return;
          } catch (_) {}
        }
      }
    }

    final clusters = await _map!.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(coordinate),
      RenderedQueryOptions(
        layerIds: [ClusterHelper.clusterLayerId],
        filter: null,
      ),
    );

    if (clusters.isNotEmpty) {
      await _zoomIntoCluster();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
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

        createdMap.setOnMapTapListener((context) {
          unawaited(_processMapTap(context.touchPosition));
        });
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
