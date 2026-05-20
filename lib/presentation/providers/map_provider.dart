import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/core/utils/map_helpers/permission_request.dart';
import 'package:street_team/data/map_engine/map_engine.dart';
import 'package:street_team/data/map_engine/mapbox_map_engine.dart';

final mapEngineProvider = Provider<MapEngine>((ref) {
  return MapboxMapEngine();
});

//user location provider

final userLocationProvider = StreamProvider<geo.LatLng>((ref) async* {
  final granted = await requestLocationPermission();

  if (!granted) {
    yield geo.LatLng(-1.9441, 30.0619);
    return;
  }

  final currentPosition = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
    ),
  );

  yield geo.LatLng(currentPosition.latitude, currentPosition.longitude);

  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,

      distanceFilter: 5,
    ),
  ).map((position) => geo.LatLng(position.latitude, position.longitude));
});
