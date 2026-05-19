import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:street_team/data/models/organization_feature.dart';

class MapRepository {
  Future<List<OrganizationFeature>> loadOrganizations() async {
    final jsonString = await rootBundle.loadString(
      'assets/mock/mock_organizations.json',
    );

    final decoded = jsonDecode(jsonString);
    final features = decoded is Map<String, dynamic>
        ? decoded['features']
        : null;

    if (features is! List) {
      return const <OrganizationFeature>[];
    }

    return features
        .whereType<Map<String, dynamic>>()
        .map(OrganizationFeature.fromJson)
        .where((feature) => feature.hasValidCoordinates)
        .toList(growable: false);
  }
}
