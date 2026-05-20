import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/models/organization_model.dart';

abstract class MapEngine {
  Widget buildMap({
    required geo.LatLng userLocation,
    required List<OrganizationModel> organizations,
  });

  void goToUserLocation();
}
