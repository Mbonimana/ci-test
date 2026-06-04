import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/services/local_storage/local_database_helper.dart';
import 'package:street_team/data/services/location_service.dart';

class LocationRepository {
  final LocationService _service;

  LocationRepository({LocationService? service})
    : _service = service ?? LocationService(DioClient.dio);

  Future<LocationModel> getLocationById(String id) {
    return _service.getLocationById(id);
  }

  Future<Response> submitLocation(LocationModel model) {
    return _service.submitLocation(model);
  }

  Future<Response> updateLocation(String id, LocationModel model) {
    return _service.updateLocation(id, model);
  }

  Future<List<LocationResponse>> searchLocations(String query) async {
    return _service.searchLocations(query);
  }

  //  return cached coordinates map for immediate render
  Future<List<LocationResponse>> fetchLocationsForMap() async {
    final localData = await LocalDatabaseHelper.readLocations();
    return localData.values
        .map((json) => LocationResponse.fromJson(json))
        .toList();
  }

  Future<List<LocationResponse>> fetchLocationsSince(String lastUpdatedAt) =>
      _service.getLocationsSince(lastUpdatedAt);

  Future<List<LocationResponse>> fetchMoreLocations(int page) =>
      _service.getDiscoveryResults(page);
}
