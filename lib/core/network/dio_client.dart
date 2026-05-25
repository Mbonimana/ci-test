import 'package:dio/dio.dart';
import 'package:street_team/core/utils/log_colors.dart';

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
            onRequest: (options, handler) {
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
