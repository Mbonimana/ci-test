import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:street_team/data/models/organization_model.dart';

class OrganizationRepository {
  static const String _mockPath = 'assets/mock/mock_organizations.json';

  Future<List<OrganizationModel>> loadOrganizations() async {
    try {
      final jsonString = await rootBundle.loadString(_mockPath);

      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return const [];
      }

      final features = decoded['features'];

      if (features is! List) {
        return const [];
      }

      return features
          .whereType<Map<String, dynamic>>()
          .map(OrganizationModel.fromJson)
          .where((organization) => organization.hasValidCoordinates)
          .toList(growable: false);
    } catch (e) {
      return const [];
    }
  }
}
