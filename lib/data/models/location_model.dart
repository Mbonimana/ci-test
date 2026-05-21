class LocationType {
  final int id;
  final String name;

  LocationType({required this.id, required this.name});

  factory LocationType.fromJson(Map<String, dynamic> json) =>
      LocationType(id: json['id'] as int, name: json['name'] as String);
}

class LocationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String physicalAddress;
  final List<LocationType> locationTypes;
  final String? buildingDetails;

  LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.physicalAddress,
    required this.locationTypes,
    this.buildingDetails,
  });

  factory LocationModel.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> props,
  ) {
    //  Coordinates logic
    double lat = (props['latitude'] as num?)?.toDouble() ?? 0.0;
    double lng = (props['longitude'] as num?)?.toDouble() ?? 0.0;

    // Fallback for GeoJSON structure
    if (lat == 0.0 && json['geometry'] != null) {
      final coords = json['geometry']['coordinates'] as List?;
      if (coords != null && coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    }

    //types
    final typesData =
        props['location_type_ids'] ?? props['locationTypes'] as List? ?? [];
    final List<LocationType> types = (typesData as List).map<LocationType>((e) {
      if (e is Map<String, dynamic>) return LocationType.fromJson(e);
      if (e is int) return LocationType(id: e, name: 'Type $e');
      return LocationType(id: 0, name: e.toString());
    }).toList(); // This now returns List<LocationType>

    return LocationModel(
      id: props['id'] ?? props['location_id'] ?? '',
      name:
          props['location_name'] ?? props['locationName'] ?? 'Unknown Building',
      latitude: lat,
      longitude: lng,
      physicalAddress:
          props['physical_address'] ?? props['physicalAddress'] ?? '',
      locationTypes: types,
      buildingDetails: props['building_details'] ?? props['buildingDetails'],
    );
  }

  bool get hasValidCoordinates =>
      longitude >= -180 &&
      longitude <= 180 &&
      latitude >= -90 &&
      latitude <= 90;
}
