import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/map_engine/mapbox_map_engine.dart';

final mapEngineProvider = Provider<MapEngine>((ref) {
  return MapboxMapEngine();
});
final userLocationProvider = Provider<geo.LatLng>((ref) {
  return geo.LatLng(-1.9441, 30.0619);
});
