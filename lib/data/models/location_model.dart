import 'package:street_team/data/models/user_model.dart';

class LocationModel {
  final String name;
  final String physicalAddress;
  final String shortName;
  final String nickname;
  final double latitude;
  final double longitude;
  final List<int> types;

  final String submitterServer;
  final String submitterAtName;

  final UserLocation userLocation;

  LocationModel({
    required this.name,
    required this.physicalAddress,
    required this.shortName,
    required this.nickname,
    required this.latitude,
    required this.longitude,
    required this.types,
    required this.submitterServer,
    required this.submitterAtName,
    required this.userLocation,
  });

  bool get hasValidCoordinates => latitude != 0 && longitude != 0;
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] ?? '',
      physicalAddress: json['physical_address'] ?? '',
      shortName: json['short_name'] ?? '',
      nickname: json['nickname'] ?? '',

      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,

      types: (json['types'] as List? ?? []).map((e) => e as int).toList(),

      submitterServer: json['submitter_server'] ?? '',
      submitterAtName: json['submitter_at_name'] ?? '',

      userLocation: json['user_location'] != null
          ? UserLocation.fromJson(json['user_location'])
          : UserLocation(street: '', latitude: 0.0, longitude: 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "physical_address": physicalAddress,
      "short_name": shortName,
      "nickname": nickname,
      "latitude": latitude,
      "longitude": longitude,
      "types": types,
      "submitter_server": submitterServer,
      "submitter_at_name": submitterAtName,
      "user_location": userLocation.toJson(),
    };
  }
}
