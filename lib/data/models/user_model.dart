class UserModel {
  final String identifier;
  final String name;
  final String? email;
  final String street;

  final double latitude;
  final double longitude;

  const UserModel({
    required this.identifier,
    required this.name,
    this.email,
    required this.street,
    required this.latitude,
    required this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      identifier: json['identifier']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      street: json['street'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'email': email,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, dynamic> toUserLocationJson() {
    return {'street': street, 'latitude': latitude, 'longitude': longitude};
  }

  UserModel copyWith({
    String? identifier,
    String? name,
    String? email,
    String? street,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      email: email ?? this.email,
      street: street ?? this.street,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// ----------------------------
  /// VALIDATION HELPERS
  /// ----------------------------
  bool get hasValidCoordinates => latitude != 0.0 && longitude != 0.0;

  String get formattedLocation => '$street ($latitude, $longitude)';
}
