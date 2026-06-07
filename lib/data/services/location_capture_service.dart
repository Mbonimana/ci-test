import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:street_team/core/config/env_config.dart';
import 'package:street_team/core/utils/map_helpers/permission_request.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class LocationCaptureService {
  Future<Map<String, dynamic>> buildUserLocation() async {
    final granted = await requestLocationPermission();
    if (!granted) {
      throw Exception("Location permission denied");
    }

    final position = await getCurrentPositionWithTimeout(
      accuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final placemark = placemarks.isNotEmpty ? placemarks.first : null;

    final street = _formatStreet(placemark);

    return LocationModel.buildUserLocation(
      street: street,
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _formatStreet(Placemark? p) {
    if (p == null) return "GPS location";

    final parts = [
      p.street,

      p.locality,
    ].where((e) => e != null && e.trim().isNotEmpty).map((e) => e!).toList();

    return parts.isEmpty ? "GPS location" : parts.join(", ");
  }

  Future<String> resolveSubmitterName() async {
    final jsonStr = await AuthStorageService.read(AuthStorageKeys.userProfile);

    if (jsonStr == null) return "Unknown";

    try {
      final decoded = jsonDecode(jsonStr);
      return decoded["name"]?.toString() ?? "Unknown";
    } catch (_) {
      return "Unknown";
    }
  }

  Future<String> resolveSubmitterServer() async {
    return EnvConfig.submitterServer;
  }
}
