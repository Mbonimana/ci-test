import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/entiry_model.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/models/organization_model.dart';

class OrganizationRepository {
  static const String _orgPath = 'assets/mock/organization_examples.json';
  static const String _locPath = 'assets/mock/location_examples.json';
  static const String _typePath = 'assets/mock/organization_types.json';

  Future<List<OrganizationModel>> loadOrganizations() async {
    try {
      talker.info("Loading Data: Organizations & Locations...");

      final orgString = await rootBundle.loadString(_orgPath);
      final locString = await rootBundle.loadString(_locPath);
      final typeString = await rootBundle.loadString(_typePath);

      final orgDecoded = jsonDecode(orgString);
      final locDecoded = jsonDecode(locString);
      final typeDecoded = jsonDecode(typeString) as List;

      // 1. Process Locations
      final List<dynamic> locList = _extractList(locDecoded);
      final Map<String, LocationModel> locationMap = {};

      for (var locJson in locList) {
        final loc = LocationModel.fromJson(locJson, locJson);
        locationMap[loc.id] = loc;
      }
      talker.info("Indexed ${locationMap.length} locations.");

      // 2. Process Organizations and Join
      final List<dynamic> orgList = _extractList(orgDecoded);
      final List<OrganizationModel> organizations = [];

      for (var orgJson in orgList) {
        final String locId = orgJson['location_id'] ?? '';
        final linkedLocation = locationMap[locId];

        if (linkedLocation == null) continue;

        organizations.add(
          OrganizationModel(
            id: orgJson['id']?.toString() ?? '',
            organizationName: orgJson['organization_name'] ?? 'Unknown',
            location: linkedLocation,
            organizationTypes: _parseTypes(orgJson['type_id'], typeDecoded),
            status: orgJson['status'],
            phoneNumber: orgJson['phone'],
            website: orgJson['website'],
            quickInfo: orgJson['quick_info'],
            workingHours: _parseHours(orgJson['working_hours']),
          ),
        );
      }

      talker.info("Successfully joined ${organizations.length} organizations.");
      return organizations;
    } catch (e, st) {
      talker.handle(e, st, "Join Error");
      return [];
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) return decoded['features'] ?? [];
    return [];
  }

  List<EntityType> _parseTypes(dynamic typeId, List<dynamic> typeList) {
    final typeData = typeList.firstWhere(
      (t) => t['id'] == typeId,
      orElse: () => {'id': 0, 'name': 'Business'},
    );
    return [EntityType(id: typeData['id'], name: typeData['name'])];
  }

  Map<String, List<String>> _parseHours(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map((key, value) {
      if (value is List) {
        final times = value.map((v) => "${v['open']}-${v['close']}").toList();
        return MapEntry(key.toString(), times);
      }
      return MapEntry(key.toString(), []);
    });
  }
}
