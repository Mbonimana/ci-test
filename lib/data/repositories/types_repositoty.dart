import 'package:street_team/core/network/response.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/data/services/types_service.dart';

class TypeRepository {
  final TypeService service;

  TypeRepository(this.service);

  Future<ApiResponse<List<TypeModel>>> getLocationTypes() async {
    try {
      final result = await service.getLocationTypes();

      return ApiResponse.success(result);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  Future<ApiResponse<List<TypeModel>>> getOrganizationTypes() async {
    try {
      final result = await service.getOrganizationTypes();

      return ApiResponse.success(result);
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }
}
