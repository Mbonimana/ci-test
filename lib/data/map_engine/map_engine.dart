import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/models/location_response.dart';

abstract class MapEngine {
  Widget buildMap({
    required geo.LatLng userLocation,
    required List<LocationResponse> locations,
  });

  void goToUserLocation({
    double? zoom = 12,
  });

  void goToCoordinates({
    required double latitude,
    required double longitude,
    double? zoom = 12,
  });

  void setInitialCamera({required double latitude, required double longitude});
}
