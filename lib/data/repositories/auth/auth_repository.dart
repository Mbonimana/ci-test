import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:street_team/core/network/response.dart';
import 'package:street_team/core/network/status_codes.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/services/auth/auth_service.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class AuthRepo {
  final AuthService _service = AuthService();

  // login
  Future<ApiResponse<void>> login({
    required String email,
    required String password,
  }) async {
    try {
      // step 1
      final authResponse = await _service.authenticateMurugo(
        email: email,
        password: password,
      );

      if (authResponse.statusCode != StatusCodes.success) {
        return ApiResponse.failure('Murugo authentication failed');
      }

      final murugoAccessToken = authResponse.data['access_token'];

      talker.info('Murugo access token received');

      // step 2
      final userResponse = await _service.getUserInfo(
        accessToken: murugoAccessToken,
      );

      if (userResponse.statusCode != StatusCodes.success) {
        return ApiResponse.failure('Failed to fetch user info');
      }

      final userIdentifier = userResponse.data['murugo_user_id'];
      talker.info('Murugo User ID ==> $userIdentifier');

      // step 3
      final streetTeamResponse = await _service.loginStreetTeam(
        userIdentifier: userIdentifier,
      );

      if (streetTeamResponse.statusCode != StatusCodes.success) {
        return ApiResponse.failure('Street Team login failed');
      }

      final streetTeamAccessToken = streetTeamResponse.data['access_token'];

      talker.log('Auth flow sucessed');

      // save session
      await AuthStorageService.write(
        key: AuthStorageKeys.murugoAccessToken,
        value: murugoAccessToken,
      );

      await AuthStorageService.write(
        key: AuthStorageKeys.streetTeamAccessToken,
        value: streetTeamAccessToken,
      );

      await AuthStorageService.write(
        key: AuthStorageKeys.userIdentifier,
        value: userIdentifier,
      );

      await AuthStorageService.write(
        key: AuthStorageKeys.userProfile,
        value: jsonEncode(userResponse.data),
      );

      talker.log('AUTH SESSION SAVED');

      return ApiResponse.success(null);
    } on DioException catch (e) {
      final data = e.response?.data;

      //  network erro
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return ApiResponse.failure(' Please check your internet connection.');
      }

      // http error
      if (data is Map<String, dynamic>) {
        final message =
            data['message'] ?? data['error_description'] ?? data['error'];

        if (message != null) {
          return ApiResponse.failure(message);
        }
      }

      // fallback
      return ApiResponse.failure(
        'Unexpected error occurred. Please try again.',
      );
    }
  }

  // check seesion
  Future<bool> isLoggedIn() async {
    final token = await AuthStorageService.read(
      AuthStorageKeys.streetTeamAccessToken,
    );

    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async {
    return AuthStorageService.read(AuthStorageKeys.streetTeamAccessToken);
  }

  //get user identifier(murugo user id)
  Future<String?> getUserIdentifier() async {
    return AuthStorageService.read(AuthStorageKeys.userIdentifier);
  }

  //logout
  Future<void> logout() async {
    await AuthStorageService.clear();

    talker.warning('USER LOGGED OUT');
  }
}
