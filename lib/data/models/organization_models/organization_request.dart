import 'package:street_team/data/models/organization_models/org_options_mapper.dart';

class OrganizationRequestModel {
  final String action;
  final String name;
  final String type;
  final String? phone;
  final String? quickInfo;
  final String? website;
  final String? onlineMenu;
  final int? murugoOrganizationId;
  final String? murugoLocationId;
  final String submitterServer;
  final String submitterAtName;
  final List<int> types;
  final List<int> subTypes;
  final Map<String, dynamic> userLocation;
  final Map<String, dynamic>? newLocationData;
  final Map<String, dynamic> workingHoursData;
  final List<Map<String, dynamic>> selectedOptions;
  final String? orgBuildingInfo;

  const OrganizationRequestModel({
    required this.action,
    required this.name,
    required this.type,
    required this.submitterServer,
    required this.submitterAtName,
    required this.types,
    required this.subTypes,
    required this.userLocation,
    required this.workingHoursData,
    required this.selectedOptions,
    this.newLocationData,
    this.phone,
    this.quickInfo,
    this.website,
    this.onlineMenu,
    this.murugoOrganizationId,
    this.murugoLocationId,
    this.orgBuildingInfo,
  });

  Map<String, dynamic> toJson() {
    final normalizedWorkingHours = _normalizeWorkingHoursData(workingHoursData);
    final backendPayload = buildBackendPayload(
      selectedFeatures: selectedOptions,
      onlineMenuUrl: onlineMenu ?? '',
      workingHoursData: normalizedWorkingHours,
    );

    final options = Map<String, dynamic>.from(backendPayload['options'] as Map);
    final openingHours = Map<String, dynamic>.from(
      backendPayload['working_hours'] as Map,
    );
    final onlineMenuUrl = backendPayload['online_menu_url']?.toString();
    final isNewAction = action.toUpperCase() == 'NEW';
    final locationData = newLocationData == null
        ? const <String, dynamic>{}
        : Map<String, dynamic>.from(newLocationData!);

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    List<int> parseIntList(dynamic value) {
      if (value is List) {
        return value.map((item) => parseInt(item)).whereType<int>().toList();
      }
      return const [];
    }

    final payload = <String, dynamic>{
      'action': action,
      'name': name,
      'type': type,
      'phone': phone,
      'quick_info': quickInfo,
      'website': website,
      'online_menu': _emptyToNull(onlineMenuUrl),
      'murugo_organization_id': murugoOrganizationId,
      'murugo_location_id': murugoLocationId,
      'submitter_server': submitterServer,
      'submitter_at_name': submitterAtName,
      'types': types,
      'sub_types': subTypes,
      'user_location': userLocation,
      'opening_hours': openingHours,
      'options': options,
      'org_building_info': orgBuildingInfo,
    };

    if (isNewAction) {
      payload.addAll({
        'location_name': locationData['location_name'] ?? locationData['name'],
        'short_name': locationData['short_name'],
        'nickname': locationData['nickname'],
        'physical_address': locationData['physical_address'],
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
        'location_types': parseIntList(
          locationData['location_types'] ?? locationData['types'],
        ),
      });
      payload.remove('murugo_location_id');
    } else {
      payload['murugo_location_id'] = parseInt(murugoLocationId);
    }

    return payload;
  }

  Map<String, dynamic> _normalizeWorkingHoursData(Map<String, dynamic> source) {
    return {
      'isActive': source['isActive'] ?? source['is_active'] ?? false,
      'isOpen24': source['isOpen24'] ?? source['is_open_24_hours'] ?? false,
      'isTempClosed':
          source['isTempClosed'] ?? source['is_temporary_closed'] ?? false,
      'possibleReturnDate':
          source['possibleReturnDate'] ?? source['possible_return_date'],
      'weeklyHours': source['weeklyHours'] ?? source['weekly_hours'] ?? {},
    };
  }

  String? _emptyToNull(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
