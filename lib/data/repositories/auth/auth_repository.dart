import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:street_team/core/network/exceptions.dart';
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

      talker.log('AUTH FLOW SUCCESS');

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
      if (e.response?.statusCode == StatusCodes.unauthorized) {
        throw const UnauthorizedException('Invalid email or password');
      }

      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerException(e.toString());
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
