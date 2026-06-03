class LocationModel {
  final String name;
  final String physicalAddress;
  final String? shortName;
  final String? nickname;

  final double latitude;
  final double longitude;

  final List<int> types;
  final String submitterAtName;
  final String submitterServer;
  final Map<String, dynamic> userLocation;

  LocationModel({
    required this.name,
    required this.physicalAddress,
    this.shortName,
    this.nickname,
    required this.latitude,
    required this.longitude,
    required this.types,
    required this.submitterServer,
    required this.submitterAtName,
    required this.userLocation,
  });

  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  factory LocationModel.fromJson(Map<String, dynamic> data) {
    return LocationModel(
      name: data["name"] ?? '',
      physicalAddress: data["physical_address"] ?? '',
      shortName: data["short_name"],
      nickname: data["nickname"],

      latitude: (data["latitude"] as num?)?.toDouble() ?? 0.0,
      longitude: (data["longitude"] as num?)?.toDouble() ?? 0.0,

      types: data["types"] != null ? List<int>.from(data["types"]) : [],

      submitterServer: data["submitter_server"] ?? '',
      submitterAtName: data["submitter_at_name"] ?? '',

      userLocation: data["user_location"] != null
          ? Map<String, dynamic>.from(data["user_location"])
          : {},
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
      "user_location": userLocation,
    };
  }

  static Map<String, dynamic> buildUserLocation({
    required String street,
    required double latitude,
    required double longitude,
  }) {
    return {"street": street, "latitude": latitude, "longitude": longitude};
  }
}
