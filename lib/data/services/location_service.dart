import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/core/network/network_error_handler.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class LocationService {
  final Dio _dio;

  LocationService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Exception _handleError(dynamic e) =>
      Exception(NetworkErrorHandler.toUserMessage(e));

  Future<Response> submitLocation(LocationModel model) async {
    try {
      final token = await AuthStorageService.read(
        AuthStorageKeys.streetTeamAccessToken,
      );

      final payload = model.toJson();
      return await _dio.post(
        Endpoints.submitLocation,
        data: payload,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> updateLocation(String id, LocationModel model) async {
    try {
      final res = await _dio.put(
        Endpoints.updateLocation(id),
        data: model.toJson(),
      );
      return res;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<LocationResponse>> searchLocations(String query) async {
    try {
      final response = await _dio.post(
        Endpoints.searchLocation,
        data: {"key": "name", "entry": query},
      );
      final List data = response.data;
      return data.map((json) => LocationResponse.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LocationModel> getLocationById(String id) async {
    try {
      final res = await _dio.get(Endpoints.getLocationById(id));
      final data = res.data["data"];

      return LocationModel(
        name: data["name"],
        physicalAddress: data["physical_address"],
        shortName: data["short_name"],
        nickname: data["nickname"],
        latitude: data["latitude"],
        longitude: data["longitude"],
        types: List<int>.from(data["types"]),
        submitterServer: data["submitter_server"],
        submitterAtName: data["submitter_at_name"],
        userLocation: data["user_location"] != null
            ? Map<String, dynamic>.from(data["user_location"])
            : {},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<LocationResponse>> getPaginatedLocations({int page = 1}) async {
    try {
      final String url = "${Endpoints.getLocations}&page=$page";
      final response = await _dio.get(url);

      final List data = response.data['data'];
      return data.map((json) => LocationResponse.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<LocationResponse>> getLocationsSince(String lastUpdatedAt) async {
    try {
      final String url = Endpoints.syncLocations(lastUpdatedAt);
      final response = await _dio.get(url);

      final List data = response.data['data'];
      return data.map((json) => LocationResponse.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<LocationResponse>> getDiscoveryResults(int page) async {
    return await getPaginatedLocations(page: page);
  }
}
