import 'entiry_model.dart';
import 'location_model.dart';

class OrganizationModel {
  final String id;
  final String organizationName;
  final List<EntityType> organizationTypes;
  final LocationModel location;

  final String? status;
  final String? phoneNumber;
  final String? website;
  final String? quickInfo;
  final Map<String, List<String>>? workingHours;

  OrganizationModel({
    required this.id,
    required this.organizationName,
    required this.organizationTypes,
    required this.location,
    this.status,
    this.phoneNumber,
    this.website,
    this.quickInfo,
    this.workingHours,
  });

  String get primaryType =>
      organizationTypes.isNotEmpty ? organizationTypes.first.name : 'Business';

  Map<String, dynamic> toGeoJsonFeature() {
    return {
      'type': 'Feature',
      'id': id,
      'geometry': {
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude],
      },
      'properties': {
        'organizationName': organizationName,
        'organizationType': primaryType,
        'locationName': location.name,
        'physicalAddress': location.physicalAddress,
        'status': status,
      },
    };
  }
}
