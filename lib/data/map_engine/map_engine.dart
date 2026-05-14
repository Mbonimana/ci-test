import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;

abstract class MapEngine {
  Widget buildMap({
    required geo.LatLng userLocation,
  });

  void goToUserLocation();
}