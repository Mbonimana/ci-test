import 'package:dio/dio.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/core/network/exceptions.dart';
import 'package:street_team/core/network/status_codes.dart';
import 'package:street_team/data/models/types_model.dart';

class TypeService {
  final Dio dio = DioClient.dio;

  Future<List<TypeModel>> getLocationTypes() async {
    try {
      final response = await dio.get(Endpoints.getLocationTypes);

      if (response.statusCode == StatusCodes.success) {
        final List data = response.data['data'];

        return data.map((e) => TypeModel.fromJson(e)).toList();
      }

      throw const ServerException('Failed to fetch location types');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<TypeModel>> getOrganizationTypes() async {
    try {
      final response = await dio.get(Endpoints.getOrganizationTypes);

      if (response.statusCode == StatusCodes.success) {
        final List data = response.data['data'];

        return data.map((e) => TypeModel.fromJson(e)).toList();
      }

      throw const ServerException('Failed to fetch organization types');
    } on DioException catch (e) {
      throw NetworkException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
