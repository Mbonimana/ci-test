import 'package:street_team/data/models/organization_properties.dart';

class OrganizationFeature {
  const OrganizationFeature({
    required this.id,
    required this.longitude,
    required this.latitude,
    required this.properties,
  });

  final String? id;
  final double longitude;
  final double latitude;
  final OrganizationProperties properties;

  factory OrganizationFeature.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'];
    final coordinates = geometry is Map<String, dynamic>
        ? geometry['coordinates']
        : null;
    final properties = json['properties'];

    final longitude = _readLongitude(coordinates);
    final latitude = _readLatitude(coordinates);

    return OrganizationFeature(
      id: json['id']?.toString(),
      longitude: longitude,
      latitude: latitude,
      properties: properties is Map<String, dynamic>
          ? OrganizationProperties.fromJson(properties)
          : const OrganizationProperties(
              locationId: '',
              organizationName: '',
              organizationTypes: <String>[],
              physicalAddress: '',
              locationName: '',
            ),
    );
  }

  String get displayName => properties.organizationName;

  String get primaryType => properties.primaryType;

  bool get hasValidCoordinates => longitude.isFinite && latitude.isFinite;
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
