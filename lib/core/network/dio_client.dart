import 'package:dio/dio.dart';
import 'package:street_team/core/network/network_error_handler.dart';
import 'package:street_team/core/utils/logger_helper.dart';
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

              AppLogger.request(
                method: options.method,
                url: options.uri.toString(),
                headers: options.headers,
                body: options.data,
              );

              return handler.next(options);
            },

            onResponse: (response, handler) {
              AppLogger.response(
                statusCode: response.statusCode ?? 0,
                url: response.requestOptions.uri.toString(),
                data: response.data,
              );

              return handler.next(response);
            },

            onError: (error, handler) {
              final userMessage = NetworkErrorHandler.toUserMessage(error);

              AppLogger.error(
                statusCode: error.response?.statusCode,
                url: error.requestOptions.uri.toString(),
                error: userMessage,
              );

              return handler.next(error.copyWith(message: userMessage));
            },
          ),
        );
}
