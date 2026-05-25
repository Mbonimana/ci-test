import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

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
          PrettyDioLogger(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseHeader: true,
            responseBody: true,
            error: true,
            compact: false,
            maxWidth: 120,
          ),
        );
}
