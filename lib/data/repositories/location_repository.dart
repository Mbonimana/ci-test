import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/services/location_service.dart';

class LocationRepository {
  final LocationService _service;
  LocationRepository(this._service);

  Future<List<LocationModel>> getLocations() async {
    try {
      final rawList = await _service.loadLocationsRaw();
      return rawList.map((json) => LocationModel.fromJson(json, json)).toList();
    } catch (e, st) {
      talker.handle(e, st, "LocationRepository: Error loading locations");
      return [];
    }
  }
}
