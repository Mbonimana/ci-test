import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/utils/map_helpers/camera_contols.dart';
import 'package:street_team/core/utils/map_helpers/icon_helper.dart';
import 'package:street_team/data/map_engine/mapbox_map_engine.dart'; 
import 'package:street_team/data/models/location_models/location_response.dart';

//  mock classes for external dependencies
class MockMapCameraController extends Mock implements MapCameraController {}

class MockIconHelper extends Mock implements IconHelper {}

class MockMapboxMap extends Mock implements MapboxMap {}

class MockStyle extends Mock implements StyleManager {}

class MockLocationComponent extends Mock implements LocationSettings {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail to handle custom classes
    registerFallbackValue(geo.LatLng(0.0, 0.0));
    registerFallbackValue(CameraOptions());
  });

  group('MapboxMapEngine Tests', () {
    late MapboxMapEngine engine;

    setUp(() {
      engine = MapboxMapEngine();
    });

    test('setInitialCamera updates initial camera coordinates', () {
      const latitude = 45.0;
      const longitude = -75.0;

      engine.setInitialCamera(latitude: latitude, longitude: longitude);

      expect(engine.cameraController.initialLatitude, latitude);
      expect(engine.cameraController.initialLongitude, longitude);
    });

    test('buildMap returns widget with correct parameters', () {
      final userLocation = geo.LatLng(10.0, 20.0);
      final locations = <LocationResponse>[];

      final widget = engine.buildMap(
        userLocation: userLocation,
        locations: locations,
      );

      expect(widget, isA<StatefulWidget>());
      // setUserLocation does not change the initial camera values; those
      // remain the defaults until setInitialCamera is called.
      expect(engine.cameraController.initialLatitude, -1.9441);
      expect(engine.cameraController.initialLongitude, 30.0619);
    });
  });

  group('MapboxMapView Widget Tests', () {
    late MockIconHelper mockIconHelper;
    late MapCameraController cameraController;

    setUp(() {
      mockIconHelper = MockIconHelper();
      cameraController = MapCameraController();
      cameraController.setInitialCamera(latitude: 45.0, longitude: -75.0);

      // Stub icon helper calls to return empty image data
      when(
        () => mockIconHelper.getMarkerImageOnly(any()),
      ).thenAnswer((_) async => Uint8List(0));
    });

    testWidgets('MapboxMapView renders the MapWidget correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapboxMapEngine().buildMap(
              userLocation: geo.LatLng(45.0, -75.0),
              locations: [],
            ),
          ),
        ),
      );

      // Verify that the MapWidget is present in the tree
      final mapWidgetFinder = find.byKey(const ValueKey('mapbox-map-widget'));
      expect(mapWidgetFinder, findsOneWidget);

      final MapWidget mapWidget = tester.widget<MapWidget>(mapWidgetFinder);
      expect(mapWidget.styleUri, MapboxStyles.MAPBOX_STREETS);
    });

  
    testWidgets('MapboxMapView exposes onMapCreated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapboxMapEngine().buildMap(
              userLocation: geo.LatLng(45.0, -75.0),
              locations: [],
            ),
          ),
        ),
      );

      final mapWidgetFinder = find.byKey(const ValueKey('mapbox-map-widget'));
      final MapWidget mapWidget = tester.widget<MapWidget>(mapWidgetFinder);

      expect(mapWidget.onMapCreated, isNotNull);
    });
  });
}
