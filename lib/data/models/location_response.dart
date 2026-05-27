import 'package:street_team/data/models/organization_response.dart';

class LocationTypeResponse {
  final int id;
  final String name;

  LocationTypeResponse({required this.id, required this.name});

  factory LocationTypeResponse.fromJson(Map<String, dynamic> json) {
    return LocationTypeResponse(id: json['id'], name: json['name'] ?? '');
  }
}

class LocationResponse {
  final int id;
  final String name;
  final String? shortName;
  final String? nickname;
  final String physicalAddress;
  final double latitude;
  final double longitude;
  final List<LocationTypeResponse> types;
  final List<OrganizationResponseModel> organizations;

  LocationResponse({
    required this.id,
    required this.name,
    this.shortName,
    this.nickname,
    required this.physicalAddress,
    required this.latitude,
    required this.longitude,
    required this.types,
    required this.organizations,
  });

  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  String get mapLabel => (nickname != null && nickname!.isNotEmpty)
      ? nickname!
      : (shortName != null && shortName!.isNotEmpty)
      ? shortName!
      : name;

  String get primaryTypeName =>
      types.isNotEmpty ? types.first.name : 'Location';

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      id: json['murugo_location_id'] ?? 0,
      name: json['name'] ?? '',
      shortName: json['short_name'],
      nickname: json['nickname'],
      physicalAddress: json['physical_address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      types:
          (json['types'] as List?)
              ?.map((t) => LocationTypeResponse.fromJson(t))
              .toList() ??
          [],
      organizations:
          (json['organizations'] as List?)
              ?.map(
                (organization) => OrganizationResponseModel.fromJson(
                  Map<String, dynamic>.from(organization),
                ),
              )
              .toList() ??
          [],
    );
  }
}
