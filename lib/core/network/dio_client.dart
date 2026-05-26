import 'package:dio/dio.dart';
import 'package:street_team/core/utils/logger_colors.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_service.dart';

class DioClient {
  static final Dio dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              //streeet team acess token
              final token = await AuthStorageService.read(
                AuthStorageKeys.streetTeamAccessToken,
              );

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              PrettyDioLogger.request(
                options.method,
                options.uri.toString(),
                options.headers,
                options.data,
              );

              return handler.next(options);
            },
            onResponse: (response, handler) {
              PrettyDioLogger.success(
                response.statusCode ?? 0,
                response.requestOptions.uri.toString(),
                response.data,
              );

              return handler.next(response);
            },
            onError: (error, handler) {
              PrettyDioLogger.error(
                error.response?.statusCode,
                error.requestOptions.uri.toString(),
                error.response?.data ?? error.message,
              );

              return handler.next(error);
            },
          ),
        );
}
