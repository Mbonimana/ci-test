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
      talker.info("Loading mock organizations...");

      final orgString = await rootBundle.loadString(_orgPath);
      final locString = await rootBundle.loadString(_locPath);
      final typeString = await rootBundle.loadString(_typePath);

      final orgDecoded = jsonDecode(orgString);
      final locDecoded = jsonDecode(locString);
      final typeDecoded = jsonDecode(typeString) as List;

      // locations
      final List<dynamic> locList = _extractList(locDecoded);

      final Map<String, LocationModel> locationMap = {
        for (final locJson in locList)
          locJson['id'].toString(): LocationModel.fromJson(locJson),
      };

      talker.info("Indexed ${locationMap.length} locations");

      // organization
      final List<dynamic> orgList = _extractList(orgDecoded);

      final List<OrganizationModel> organizations = [];

      for (final orgJson in orgList) {
        final String locId = orgJson['location_id']?.toString() ?? '';

        final location = locationMap[locId];

        // skip invalid links
        if (location == null) continue;

        organizations.add(
          OrganizationModel(
            id: orgJson['id']?.toString() ?? '',
            organizationName: orgJson['organization_name'] ?? 'Unknown',
            location: location,

            organizationTypes: _parseTypes(orgJson['type_id'], typeDecoded),

            status: orgJson['status'],
            phoneNumber: orgJson['phone'],
            website: orgJson['website'],
            quickInfo: orgJson['quick_info'],
            workingHours: _parseHours(orgJson['working_hours']),
          ),
        );
      }

      talker.info("Loaded ${organizations.length} organizations");
      return organizations;
    } catch (e, st) {
      talker.handle(e, st, "OrganizationRepository.loadOrganizations");
      return [];
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      return decoded['data'] ?? decoded['features'] ?? [];
    }
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
        return MapEntry(
          key.toString(),
          value.map((v) => "${v['open']}-${v['close']}").toList(),
        );
      }
      return MapEntry(key.toString(), []);
    });
  }
}
