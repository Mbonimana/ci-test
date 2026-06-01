import 'package:latlong2/latlong.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapCameraController {
  MapboxMap? _map;

  geo.LatLng? _userLocation;

  double initialLatitude;
  double initialLongitude;
  double initialZoom;

  MapCameraController({
    this.initialLatitude = -1.9441,
    this.initialLongitude = 30.0619,
    this.initialZoom = 14,
  });

  void attachMap(MapboxMap map) {
    _map = map;
  }

  void setUserLocation(geo.LatLng location) {
    _userLocation = location;
  }

  void setInitialCamera({
    required double latitude,
    required double longitude,
    double zoom = 18,
  }) {
    initialLatitude = latitude;
    initialLongitude = longitude;
    initialZoom = zoom;
  }

  void goToUserLocation() {
    if (_userLocation == null) {
      return;
    }

    flyTo(
      latitude: _userLocation!.latitude,
      longitude: _userLocation!.longitude,
      zoom: 18,
    );
  }

  void flyTo({
    required double latitude,
    required double longitude,
    double zoom = 18,
  }) {
    if (_map == null) {
      return;
    }

    _map!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: zoom,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  void zoomIn() async {
    if (_map == null) {
      return;
    }

    final state = await _map!.getCameraState();

    _map!.flyTo(
      CameraOptions(zoom: state.zoom + 1),
      MapAnimationOptions(duration: 300),
    );
  }

  void zoomOut() async {
    if (_map == null) {
      return;
    }

    final state = await _map!.getCameraState();

    _map!.flyTo(
      CameraOptions(zoom: state.zoom - 1),
      MapAnimationOptions(duration: 300),
    );
  }
}
