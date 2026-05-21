import 'dart:convert';

import 'package:flutter/services.dart';

class LocationService {
  Future<List<dynamic>> loadLocationsRaw() async {
    final String response = await rootBundle.loadString(
      'assets/mock/location_examples.json',
    );
    return json.decode(response) as List<dynamic>;
  }
}
