class UserLocation {
  final String street;
  final double latitude;
  final double longitude;

  UserLocation({
    required this.street,
    required this.latitude,
    required this.longitude,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      street: json['street'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"street": street, "latitude": latitude, "longitude": longitude};
  }
}
