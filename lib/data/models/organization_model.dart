class OrganizationModel {
  const OrganizationModel({
    required this.id,
    required this.longitude,
    required this.latitude,
    required this.locationId,
    required this.organizationName,
    required this.organizationTypes,
    required this.physicalAddress,
    required this.locationName,

    this.shortName,
    this.nickname,
    this.organizationSubtypes = const [],
    this.legacyType = false,
    this.phoneNumber,
    this.website,
    this.quickInfo,
    this.buildingDetails,
    this.open24Hours = false,
    this.status,
  });

  //location

  final String? id;
  final double longitude;
  final double latitude;
  final String locationId;
  final String organizationName;
  final List<String> organizationTypes;
  final String physicalAddress;
  final String locationName;
  final String? shortName;
  final String? nickname;
  final List<String> organizationSubtypes;
  final bool legacyType;
  final String? phoneNumber;
  final String? website;
  final String? quickInfo;
  final String? buildingDetails;
  final bool open24Hours;
  final String? status;

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'];

    final properties = (json['properties'] as Map<String, dynamic>?) ?? {};

    return OrganizationModel(
      id: json['id']?.toString(),

      longitude: _readLongitude(coordinates),
      latitude: _readLatitude(coordinates),

      locationId: _readString(properties['locationId']),
      organizationName: _readString(properties['organizationName']),
      organizationTypes: _readStringList(properties['organizationTypes']),
      physicalAddress: _readString(properties['physicalAddress']),
      locationName: _readString(properties['locationName']),

      shortName: _readNullableString(properties['shortName']),
      nickname: _readNullableString(properties['nickname']),
      organizationSubtypes: _readStringList(properties['organizationSubtypes']),
      legacyType: properties['legacyType'] == true,
      phoneNumber: _readNullableString(properties['phoneNumber']),
      website: _readNullableString(properties['website']),
      quickInfo: _readNullableString(properties['quickInfo']),
      buildingDetails: _readNullableString(properties['buildingDetails']),
      open24Hours: properties['open24Hours'] == true,
      status: _readNullableString(properties['status']),
    );
  }

  Map<String, dynamic> toGeoJsonFeature() {
    return {
      'type': 'Feature',
      'id': id,
      'geometry': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'properties': toPropertiesJson(),
    };
  }

  Map<String, dynamic> toPropertiesJson() {
    return {
      'locationId': locationId,
      'organizationName': organizationName,
      'organizationTypes': organizationTypes,
      'physicalAddress': physicalAddress,
      'locationName': locationName,

      'shortName': shortName,
      'nickname': nickname,
      'organizationSubtypes': organizationSubtypes,
      'legacyType': legacyType,
      'phoneNumber': phoneNumber,
      'website': website,
      'quickInfo': quickInfo,
      'buildingDetails': buildingDetails,
      'open24Hours': open24Hours,
      'status': status,
    };
  }

  String get displayName => organizationName;

  String get primaryType {
    if (organizationTypes.isEmpty) {
      return 'Business Other';
    }

    return organizationTypes.first;
  }

  bool get hasValidCoordinates {
    return longitude.isFinite &&
        latitude.isFinite &&
        longitude >= -180 &&
        longitude <= 180 &&
        latitude >= -90 &&
        latitude <= 90;
  }
}

double _readLongitude(dynamic coordinates) {
  if (coordinates is List && coordinates.length >= 2) {
    final value = coordinates[0];

    if (value is num) {
      return value.toDouble();
    }
  }

  return double.nan;
}

double _readLatitude(dynamic coordinates) {
  if (coordinates is List && coordinates.length >= 2) {
    final value = coordinates[1];

    if (value is num) {
      return value.toDouble();
    }
  }

  return double.nan;
}

String _readString(dynamic value) {
  if (value is String) {
    return value;
  }

  return '';
}

String? _readNullableString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  return null;
}

List<String> _readStringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }

  return value.whereType<String>().toList(growable: false);
}
