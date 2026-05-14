import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as geo;
import 'package:street_team/data/map_engine/map_box_engine.dart';
import 'package:street_team/data/map_engine/map_engine.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapEngine engine = MapboxMapEngine();

  final geo.LatLng userLocation = geo.LatLng(-1.9441, 30.0619);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: engine.buildMap(userLocation: userLocation),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () {
          engine.goToUserLocation();
        },
      ),
    );
  }
}
