import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/network/dio_client.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/core/network/exceptions.dart';
import 'package:street_team/core/network/status_codes.dart';
import 'package:street_team/data/models/types_model.dart';
import 'package:street_team/data/services/types_service.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockHttpClientAdapter mockAdapter;
  late TypeService typeService;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    const MethodChannel secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'read') return null;
          if (methodCall.method == 'deleteAll') return null;
          if (methodCall.method == 'write') return null;
          return null;
        });

    mockAdapter = MockHttpClientAdapter();

    DioClient.dio.httpClientAdapter = mockAdapter;

    typeService = TypeService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  ResponseBody jsonResponse(Map<String, dynamic> data, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  group('getLocationTypes', () {
    final successJsonPayload = {
      'data': [
        {'id': 1, 'name': 'Hospital'},
        {'id': 2, 'name': 'School'},
      ],
    };

    test(
      'returns List<TypeModel> when server responds with 200 (Success)',
      () async {
        when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer(
          (_) async => jsonResponse(successJsonPayload, StatusCodes.success),
        );

        final result = await typeService.getLocationTypes();

        expect(result, isA<List<TypeModel>>());
        expect(result.length, 2);
        expect(result[0].id, 1);
        expect(result[0].name, 'Hospital');
      },
    );

    test(
      'throws ServerException when server returns non-success status code',
      () async {
        when(
          () => mockAdapter.fetch(any(), any(), any()),
        ).thenAnswer((_) async => jsonResponse({}, 500));

        expect(
          () => typeService.getLocationTypes(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.toString(),
              'error message',
              contains('500'),
            ),
          ),
        );
      },
    );

    test('throws NetworkException when a DioException occurs', () async {
      // Simulate a network failure on the adapter level
      when(() => mockAdapter.fetch(any(), any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: Endpoints.getLocationTypes),
          message: 'Connection timed out',
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => typeService.getLocationTypes(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.toString(),
            'error message',
            contains('Connection timed out'),
          ),
        ),
      );
    });

    test('throws ServerException when any other parsing error occurs', () async {
      // Return invalid data map format missing 'data' key to force parsing crash
      when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer(
        (_) async => jsonResponse({'invalid_key': []}, StatusCodes.success),
      );

      expect(
        () => typeService.getLocationTypes(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getOrganizationTypes', () {
    final successJsonPayload = {
      'data': [
        {'id': 10, 'name': 'NGO'},
        {'id': 11, 'name': 'Private'},
      ],
    };

    test(
      'returns List<TypeModel> when server responds with 200 (Success)',
      () async {
        when(() => mockAdapter.fetch(any(), any(), any())).thenAnswer(
          (_) async => jsonResponse(successJsonPayload, StatusCodes.success),
        );

        final result = await typeService.getOrganizationTypes();

        expect(result, isA<List<TypeModel>>());
        expect(result.length, 2);
        expect(result[0].id, 10);
        expect(result[0].name, 'NGO');
      },
    );

    test(
      'throws ServerException when server returns non-success status code',
      () async {
        when(
          () => mockAdapter.fetch(any(), any(), any()),
        ).thenAnswer((_) async => jsonResponse({}, 404));

        expect(
          () => typeService.getOrganizationTypes(),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.toString(),
              'error message',
              contains('404'),
            ),
          ),
        );
      },
    );

    test('throws NetworkException when a DioException occurs', () async {
      when(() => mockAdapter.fetch(any(), any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: Endpoints.getOrganizationTypes),
          message: 'Host unreachable',
        ),
      );

      expect(
        () => typeService.getOrganizationTypes(),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.toString(),
            'error message',
            contains('Host unreachable'),
          ),
        ),
      );
    });
  });
}
