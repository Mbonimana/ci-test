class OrganizationProperties {
  const OrganizationProperties({
    required this.locationId,
    required this.organizationName,
    required this.organizationTypes,
    required this.physicalAddress,
    required this.locationName,
  });

  final String locationId;
  final String organizationName;
  final List<String> organizationTypes;
  final String physicalAddress;
  final String locationName;

  factory OrganizationProperties.fromJson(Map<String, dynamic> json) {
    return OrganizationProperties(
      locationId: _readString(json['locationId']),
      organizationName: _readString(json['organizationName']),
      organizationTypes: _readStringList(json['organizationTypes']),
      physicalAddress: _readString(json['physicalAddress']),
      locationName: _readString(json['locationName']),
    );
  }

  String get primaryType {
    if (organizationTypes.isEmpty) {
      return 'Business Other';
    }

    return organizationTypes.first;
  }
}

String _readString(dynamic value) {
  if (value is String) {
    return value;
  }

  return '';
}

List<String> _readStringList(dynamic value) {
  if (value is! List) {
    return const <String>[];
  }

  return value.whereType<String>().toList(growable: false);
}
