import 'dart:io';

import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/organization_models/organization_request.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class OrganizationService {
  final Dio _dio;

  OrganizationService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  String _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? data['detail'])?.toString() ??
          data.toString();
    }
    if (data is List) {
      return data.join(', ');
    }
    return data?.toString() ?? 'Unknown server error';
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      final response = e.response;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        return 'Network error: Check your internet connection and try again.';
      }

      if (response != null) {
        final message = _extractServerMessage(response.data);
        return 'Request failed [${response.statusCode}]: $message';
      }

      return 'Request failed: ${e.message ?? e.error ?? 'Unknown dio error'}';
    }

    return 'Unexpected error: $e';
  }

  Future<Response<dynamic>> submitOrganization(
    OrganizationRequestModel model,
  ) async {
    try {
      talker.info('OrganizationService.submitOrganization started');
      final token = await AuthStorageService.read(
        AuthStorageKeys.streetTeamAccessToken,
      );
      final payload = model.toJson();
      talker.debug('Organization payload => $payload');

      final response = await _dio.post(
        Endpoints.submitOrganization,
        data: payload,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      talker.info(
        'OrganizationService.submitOrganization success: ${response.statusCode}',
      );
      return response;
    } on DioException catch (e, st) {
      talker.error(
        'OrganizationService.submitOrganization dio failure. '
        'status=${e.response?.statusCode} '
        'url=${e.requestOptions.uri} '
        'response=${e.response?.data}',
        e,
        st,
      );
      throw Exception(_handleError(e));
    } catch (e, st) {
      talker.error(
        'OrganizationService.submitOrganization unexpected failure: $e',
        e,
        st,
      );
      throw Exception(_handleError(e));
    }
  }

  Future<Response<dynamic>> updateOrganization(
    String id,
    OrganizationRequestModel model,
  ) async {
    try {
      talker.info('OrganizationService.updateOrganization started');
      final token = await AuthStorageService.read(
        AuthStorageKeys.streetTeamAccessToken,
      );
      final payload = model.toJson();
      talker.debug('Organization update payload => $payload');

      final response = await _dio.put(
        Endpoints.updateOrganization(id),
        data: payload,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      talker.info(
        'OrganizationService.updateOrganization success: ${response.statusCode}',
      );
      return response;
    } on DioException catch (e, st) {
      talker.error(
        'OrganizationService.updateOrganization dio failure. '
        'status=${e.response?.statusCode} '
        'url=${e.requestOptions.uri} '
        'response=${e.response?.data}',
        e,
        st,
      );
      throw Exception(_handleError(e));
    } catch (e, st) {
      talker.error(
        'OrganizationService.updateOrganization unexpected failure: $e',
        e,
        st,
      );
      throw Exception(_handleError(e));
    }
  }
}
