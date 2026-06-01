import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/response.dart';
import 'package:street_team/core/utils/talker_helper.dart';
import 'package:street_team/data/models/organization_models/organization_request.dart';
import 'package:street_team/data/services/organization_service.dart';

class OrganizationRepository {
  final OrganizationService _service;

  OrganizationRepository({OrganizationService? service})
    : _service = service ?? OrganizationService(DioClient.dio);

  Future<ApiResponse<Response<dynamic>>> submitOrganization(
    OrganizationRequestModel model,
  ) async {
    try {
      talker.info('OrganizationRepository.submitOrganization sending request');
      final response = await _service.submitOrganization(model);
      talker.info(
        'OrganizationRepository.submitOrganization success: ${response.statusCode}',
      );
      return ApiResponse.success(response);
    } catch (e, st) {
      talker.error(
        'OrganizationRepository.submitOrganization failed: $e',
        e,
        st,
      );
      return ApiResponse.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ApiResponse<Response<dynamic>>> updateOrganization(
    String id,
    OrganizationRequestModel model,
  ) async {
    try {
      talker.info('OrganizationRepository.updateOrganization sending request');
      final response = await _service.updateOrganization(id, model);
      talker.info(
        'OrganizationRepository.updateOrganization success: ${response.statusCode}',
      );
      return ApiResponse.success(response);
    } catch (e, st) {
      talker.error(
        'OrganizationRepository.updateOrganization failed: $e',
        e,
        st,
      );
      return ApiResponse.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
