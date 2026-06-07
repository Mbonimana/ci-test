import 'package:street_team/data/models/organization_models/organization_response.dart';
import 'package:street_team/data/models/types_model.dart';

List<Map<String, dynamic>> organizationOptions(List<TypeModel> orgTypes) {
  return orgTypes.map((org) {
    final List<dynamic> subTypesList =
        (org as dynamic).subTypes ?? (org as dynamic).sub_types ?? [];
    final List<String> subtypeNames = subTypesList
        .map((sub) => (sub as dynamic).name.toString())
        .toList();

    return {'type': org.name, 'id': org.id, 'subtypes': subtypeNames};
  }).toList();
}

List<SubTypeModel> subtypeOptionsForSelection(
  List<TypeModel> orgTypes,
  List<String> selectedOrgTypes,
) {
  final selectedTypeSet = selectedOrgTypes.toSet();
  final Map<int, SubTypeModel> result = {};

  for (final org in orgTypes) {
    if (!selectedTypeSet.contains(org.name)) {
      continue;
    }

    for (final subType in org.subTypes) {
      result[subType.id] = subType;
    }
  }

  return result.values.toList();
}

Map<int, String> subtypeNameMapForSelection(
  List<TypeModel> orgTypes,
  List<String> selectedOrgTypes,
) {
  final map = <int, String>{};
  for (final subType in subtypeOptionsForSelection(
    orgTypes,
    selectedOrgTypes,
  )) {
    map[subType.id] = subType.name;
  }
  return map;
}

List<int> selectedTypeIds(
  List<TypeModel> orgTypes,
  List<String> selectedOrgTypes,
) {
  return orgTypes
      .where((org) => selectedOrgTypes.contains(org.name))
      .map((org) => org.id)
      .toList();
}

List<int> selectedSubTypeIds(
  List<TypeModel> orgTypes,
  List<String> selectedOrgTypes,
  List<int> selectedSubtypes,
) {
  final validSubtypeIds = subtypeOptionsForSelection(
    orgTypes,
    selectedOrgTypes,
  ).map((subType) => subType.id).toSet();

  return selectedSubtypes.where(validSubtypeIds.contains).toList();
}

Set<int> extractSubTypeIds(List<dynamic> rawSubTypes) {
  final ids = <int>{};
  for (final item in rawSubTypes) {
    if (item is int) {
      ids.add(item);
      continue;
    }
    if (item is String) {
      final parsed = int.tryParse(item);
      if (parsed != null) ids.add(parsed);
      continue;
    }
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final parsed = int.tryParse((map['id'] ?? map['sub_type_id']).toString());
      if (parsed != null) ids.add(parsed);
    }
  }
  return ids;
}

Set<String> extractSubTypeNames(List<dynamic> rawSubTypes) {
  final names = <String>{};
  for (final item in rawSubTypes) {
    if (item is String && item.trim().isNotEmpty) {
      names.add(item.trim().toLowerCase());
      continue;
    }
    if (item is Map) {
      final map = Map<String, dynamic>.from(item);
      final value = (map['name'] ?? map['label']).toString().trim();
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        names.add(value.toLowerCase());
      }
    }
  }
  return names;
}

Map<String, dynamic>? workingHoursFromOrganization(
  OrganizationResponseModel organization,
) {
  for (final candidate in [
    organization.openingHours,
    organization.normalOpeningHours,
    organization.weekendOpeningHours,
  ]) {
    final normalized = _normalizeWorkingHoursSource(candidate);
    if (normalized != null) {
      return normalized;
    }
  }

  if (organization.isActive != null ||
      organization.isOpen24Hours != null ||
      organization.isTemporaryClosed != null) {
    return {
      'is_active': organization.isActive == 1,
      'is_open_24_hours': organization.isOpen24Hours == 1,
      'is_temporary_closed': organization.isTemporaryClosed == 1,
      'possible_return_date': null,
      'weekly_hours': const <String, dynamic>{},
    };
  }

  return null;
}

List<Map<String, dynamic>> organizationOptionsFromOrganization(
  OrganizationResponseModel organization,
) {
  final selectedNames = selectedOrganizationOptionNames(organization);

  return organizationFeatureOptionsCatalog()
      .where((item) => selectedNames.contains(_normalizedText(item['name'])))
      .map<Map<String, dynamic>>((item) => item)
      .toList();
}

List<Map<String, dynamic>> organizationFeatureOptionsCatalog() {
  return _organizationFeatureCatalog
      .map<Map<String, dynamic>>((item) => {'id': item.id, 'name': item.label})
      .toList();
}

Set<String> selectedOrganizationOptionNames(
  OrganizationResponseModel organization,
) {
  final options = _normalizedOptions(organization.options);
  final selectedNames = <String>{};

  for (final definition in _organizationOptionDefinitions) {
    if (definition.isEnabled(options, organization)) {
      selectedNames.add(_normalizedText(definition.label));
    }
  }

  if ((organization.onlineMenu ?? '').trim().isNotEmpty) {
    selectedNames.add('online menu');
  }

  return selectedNames;
}

Map<String, dynamic>? _normalizeWorkingHoursSource(dynamic source) {
  if (source is! Map) return null;

  final map = Map<String, dynamic>.from(source);
  final weeklySource = map['weekly_hours'] ?? map['weeklyHours'] ?? map;

  return {
    'is_active': _asBool(map['is_active'] ?? map['isActive']),
    'is_open_24_hours': _asBool(map['is_open_24_hours'] ?? map['isOpen24']),
    'is_temporary_closed': _asBool(
      map['is_temporary_closed'] ?? map['isTempClosed'],
    ),
    'possible_return_date':
        map['possible_return_date'] ?? map['possibleReturnDate'],
    'weekly_hours': _normalizeWeeklyHours(weeklySource),
  };
}

Map<String, dynamic> _normalizeWeeklyHours(dynamic source) {
  if (source is! Map) return const <String, dynamic>{};

  final weeklyMap = Map<String, dynamic>.from(source);
  final result = <String, dynamic>{};

  for (final entry in weeklyMap.entries) {
    final value = entry.value;
    if (value is List) {
      result[entry.key.toString()] = value;
    } else if (value is String && value.toLowerCase() == 'closed') {
      result[entry.key.toString()] = 'Closed';
    } else if (value is Map) {
      result[entry.key.toString()] = [Map<String, dynamic>.from(value)];
    }
  }

  return result;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }
  return false;
}

String _normalizedText(dynamic value) {
  return value?.toString().trim().toLowerCase() ?? '';
}

Map<String, dynamic> _normalizedOptions(Map<String, dynamic>? options) {
  return options == null
      ? const <String, dynamic>{}
      : Map<String, dynamic>.from(options);
}

class _OrganizationOptionDefinition {
  final String label;
  final List<String> optionKeys;
  final int? Function(OrganizationResponseModel organization)? legacyValue;

  const _OrganizationOptionDefinition(
    this.label,
    this.optionKeys, {
    this.legacyValue,
  });

  bool isEnabled(
    Map<String, dynamic> options,
    OrganizationResponseModel organization,
  ) {
    for (final key in optionKeys) {
      final value = options[key];
      if (value == 1 || value == true || value?.toString() == '1') {
        return true;
      }
    }

    return legacyValue?.call(organization) == 1;
  }
}

const List<_OrganizationOptionDefinition> _organizationOptionDefinitions = [
  _OrganizationOptionDefinition('Delivery Available', ['delivery_available']),
  _OrganizationOptionDefinition('Brunch Available', ['brunch_available']),
  _OrganizationOptionDefinition('Bar', ['has_bar'], legacyValue: _legacyHasBar),
  _OrganizationOptionDefinition('Work Friendly', ['work_friendly']),
  _OrganizationOptionDefinition('Wifi', [
    'has_wifi',
  ], legacyValue: _legacyHasWifi),
  _OrganizationOptionDefinition('Reservation Required', [
    'reservation_required',
  ]),
  _OrganizationOptionDefinition('ATM', ['has_ATM', 'has_atm']),
  _OrganizationOptionDefinition('Parking Available', ['has_parking']),
  _OrganizationOptionDefinition('Coffee', [
    'has_coffee',
  ], legacyValue: _legacyHasCoffee),
  _OrganizationOptionDefinition('Wheelchair Accessible', [
    'wheelchair_accessible',
  ]),
  _OrganizationOptionDefinition('Family Friendly', ['family_friendly']),
  _OrganizationOptionDefinition('Swimming Pool', ['swimming_pool']),
  _OrganizationOptionDefinition('Gym', ['has_gym']),
  _OrganizationOptionDefinition('Spa', ['has_spa']),
  _OrganizationOptionDefinition('Pool Table', ['pool_table']),
  _OrganizationOptionDefinition('Tourism', [
    'is_tourism',
  ], legacyValue: _legacyIsTourism),
  _OrganizationOptionDefinition('Nightlife', [
    'is_night_life',
  ], legacyValue: _legacyIsNightLife),
  _OrganizationOptionDefinition('Food', [
    'has_food',
  ], legacyValue: _legacyHasFood),
  _OrganizationOptionDefinition('Shopping', [
    'has_shopping',
  ], legacyValue: _legacyHasShopping),
  _OrganizationOptionDefinition('Guhemba Menu', [
    'has_guhemba_menu',
  ], legacyValue: _legacyHasGuhembaMenu),
  _OrganizationOptionDefinition('Guhemba', [
    'has_guhemba',
  ], legacyValue: _legacyHasGuhemba),
  _OrganizationOptionDefinition('Takeaway', ['has_takeaway']),
  _OrganizationOptionDefinition('Kids Activities', ['kids_activities']),
  _OrganizationOptionDefinition('Sunday School', ['sunday_school']),
  _OrganizationOptionDefinition('Outdoor Activities', ['outdoor_activities']),
];

class _OrganizationFeatureCatalogEntry {
  final int id;
  final String label;

  const _OrganizationFeatureCatalogEntry(this.id, this.label);
}

const List<_OrganizationFeatureCatalogEntry> _organizationFeatureCatalog = [
  _OrganizationFeatureCatalogEntry(2, 'Delivery Available'),
  _OrganizationFeatureCatalogEntry(4, 'Brunch Available'),
  _OrganizationFeatureCatalogEntry(6, 'Bar'),
  _OrganizationFeatureCatalogEntry(7, 'Work Friendly'),
  _OrganizationFeatureCatalogEntry(8, 'Wifi'),
  _OrganizationFeatureCatalogEntry(9, 'Reservation Required'),
  _OrganizationFeatureCatalogEntry(10, 'ATM'),
  _OrganizationFeatureCatalogEntry(11, 'Parking Available'),
  _OrganizationFeatureCatalogEntry(12, 'Coffee'),
  _OrganizationFeatureCatalogEntry(13, 'Wheelchair Accessible'),
  _OrganizationFeatureCatalogEntry(14, 'Family Friendly'),
  _OrganizationFeatureCatalogEntry(15, 'Swimming Pool'),
  _OrganizationFeatureCatalogEntry(16, 'Gym'),
  _OrganizationFeatureCatalogEntry(17, 'Spa'),
  _OrganizationFeatureCatalogEntry(18, 'Pool Table'),
  _OrganizationFeatureCatalogEntry(19, 'Tourism'),
  _OrganizationFeatureCatalogEntry(20, 'Nightlife'),
  _OrganizationFeatureCatalogEntry(21, 'Food'),
  _OrganizationFeatureCatalogEntry(22, 'Shopping'),
  _OrganizationFeatureCatalogEntry(23, 'Guhemba Menu'),
  _OrganizationFeatureCatalogEntry(24, 'Guhemba'),
  _OrganizationFeatureCatalogEntry(25, 'Takeaway'),
  _OrganizationFeatureCatalogEntry(26, 'Kids Activities'),
  _OrganizationFeatureCatalogEntry(27, 'Sunday School'),
  _OrganizationFeatureCatalogEntry(28, 'Outdoor Activities'),
  _OrganizationFeatureCatalogEntry(29, 'Online Menu'),
];

int? _legacyHasBar(OrganizationResponseModel organization) =>
    organization.hasBar;
int? _legacyHasWifi(OrganizationResponseModel organization) =>
    organization.hasWifi;
int? _legacyHasCoffee(OrganizationResponseModel organization) =>
    organization.hasCoffee;
int? _legacyIsTourism(OrganizationResponseModel organization) =>
    organization.isTourism;
int? _legacyIsNightLife(OrganizationResponseModel organization) =>
    organization.isNightLife;
int? _legacyHasFood(OrganizationResponseModel organization) =>
    organization.hasFood;
int? _legacyHasShopping(OrganizationResponseModel organization) =>
    organization.hasShopping;
int? _legacyHasGuhembaMenu(OrganizationResponseModel organization) =>
    organization.hasGuhembaMenu;
int? _legacyHasGuhemba(OrganizationResponseModel organization) =>
    organization.hasGuhemba;
