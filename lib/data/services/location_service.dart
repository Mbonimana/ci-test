import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/data/models/location_model.dart';
import 'package:street_team/data/models/user_model.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class LocationService {
  final Dio _dio = DioClient.dio;

  LocationService(Dio dio);


  Future<Response> submitLocation(LocationModel model) async {
    final token = await AuthStorageService.read(
      AuthStorageKeys.streetTeamAccessToken,
    );

    final payload = model.toJson();
    final response = await _dio.post(
      Endpoints.submitLocation,
      data: payload,
      options: Options(
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    return response;
  }

  Future<Response> updateLocation(String id, LocationModel model) async {
    final res = await _dio.put(
      Endpoints.updateLocation(id),
      data: model.toJson(),
    );
    log(" RESPONSE: ${res.data}");
    return res;
  }

  Future<LocationModel> getLocationById(String id) async {
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
      userLocation: UserLocation(
        street: data["user_location"]["street"],
        latitude: data["user_location"]["latitude"],
        longitude: data["user_location"]["longitude"],
      ),
    );
  }
}
