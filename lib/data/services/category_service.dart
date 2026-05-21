import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:street_team/data/models/entiry_model.dart';

class TypeService {
  /// Loads Organization Types (Restaurants, Coffee, etc.)
  Future<List<EntityType>> loadOrganizationTypes() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/mock/organization_types.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => EntityType.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to load Organization Types: $e");
    }
  }

  /// Loads Location Types (Food & Drink, Wellness, etc.)
  Future<List<EntityType>> loadLocationTypes() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/mock/location_types.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => EntityType.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to load Location Types: $e");
    }
  }
}
