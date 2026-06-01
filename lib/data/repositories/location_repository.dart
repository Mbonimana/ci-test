import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/models/location_response.dart';
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

  Future<List<LocationResponse>> searchLocations(String query) {
    return _service.searchLocations(query);
  }

  Future<List<LocationResponse>> fetchLocationsForMap() =>
      _service.getPaginatedLocations(page: 1);

  Future<List<LocationResponse>> fetchMoreLocations(int page) =>
      _service.getDiscoveryResults(page);
}
