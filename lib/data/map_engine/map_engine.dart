import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/models/location_models/location_response.dart';

abstract class MapEngine {
  Widget buildMap({
    required geo.LatLng userLocation,
    required List<LocationResponse> locations,
  });

  void goToUserLocation();

  void goToCoordinates({
    required double latitude,
    required double longitude,
    double zoom = 18,
  });

  void setInitialCamera({required double latitude, required double longitude});
}
