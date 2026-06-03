import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/data/models/organization_models/organization_request.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';
import 'package:street_team/data/services/organization_service.dart';

// Mocks
class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<dynamic> {}

class MockOrganizationRequestModel extends Mock
    implements OrganizationRequestModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late OrganizationService organizationService;
  late MockOrganizationRequestModel mockModel;

  const mockToken = 'test_token_123';
  final mockPayload = {'name': 'Team Alpha', 'description': 'Street Team Unit'};

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    organizationService = OrganizationService(mockDio);
    mockModel = MockOrganizationRequestModel();

    when(() => mockModel.toJson()).thenReturn(mockPayload);

    //mocksecure storage channel used by flutter_secure_storage
    const secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'read') {
            // verify that the requested key matches the expected token key
            final args = methodCall.arguments as Map<dynamic, dynamic>?;
            if (args?['key'] == AuthStorageKeys.streetTeamAccessToken) {
              return mockToken;
            }
          }
          if (methodCall.method == 'deleteAll') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    // Reset method call handler to avoid leaking state between tests
    const secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('submitOrganization', () {
    test(
      'submits successfully and returns response with correct authorization headers',
      () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);

        when(
          () => mockDio.post<dynamic>(
            Endpoints.submitOrganization,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer((_) async => mockResponse);

        final result = await organizationService.submitOrganization(mockModel);

        expect(result.statusCode, 201);
        verify(
          () => mockDio.post<dynamic>(
            Endpoints.submitOrganization,
            data: mockPayload,
            options: any(
              named: 'options',
              that: isA<Options>().having(
                (o) => o.headers?['Authorization'],
                'Authorization header',
                'Bearer $mockToken',
              ),
            ),
          ),
        ).called(1);
      },
    );

    test('throws mapped Connection Timeout message as an Exception', () async {
      when(
        () => mockDio.post<dynamic>(
          Endpoints.submitOrganization,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: Endpoints.submitOrganization),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => organizationService.submitOrganization(mockModel),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message content',
            contains('Network error: Check your internet connection'),
          ),
        ),
      );
    });

    test(
      'extracts nested server message correctly when key is "message"',
      () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: Endpoints.submitOrganization),
          statusCode: 400,
          data: {'message': 'Organization name already taken'},
        );

        when(
          () => mockDio.post<dynamic>(
            Endpoints.submitOrganization,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: Endpoints.submitOrganization),
            response: mockResponse,
          ),
        );

        expect(
          () => organizationService.submitOrganization(mockModel),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'error content',
              contains('Request failed [400]: Organization name already taken'),
            ),
          ),
        );
      },
    );

    test(
      'formats response lists into error messages when error payload is a List',
      () async {
        final mockResponse = Response(
          requestOptions: RequestOptions(path: Endpoints.submitOrganization),
          statusCode: 422,
          data: ['Name is too short', 'Description is required'],
        );

        when(
          () => mockDio.post<dynamic>(
            Endpoints.submitOrganization,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: Endpoints.submitOrganization),
            response: mockResponse,
          ),
        );

        expect(
          () => organizationService.submitOrganization(mockModel),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'error content',
              contains(
                'Request failed [422]: Name is too short, Description is required',
              ),
            ),
          ),
        );
      },
    );
  });

  group('updateOrganization', () {
    const orgId = 'org-123';

    test('calls PUT successfully on updateOrganization endpoint', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);

      when(
        () => mockDio.put<dynamic>(
          Endpoints.updateOrganization(orgId),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await organizationService.updateOrganization(
        orgId,
        mockModel,
      );

      expect(result.statusCode, 200);
      verify(
        () => mockDio.put<dynamic>(
          Endpoints.updateOrganization(orgId),
          data: mockPayload,
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test('wraps unexpected native exceptions gracefully', () async {
      when(
        () => mockDio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(const FileSystemException('Disk write failed'));

      expect(
        () => organizationService.updateOrganization(orgId, mockModel),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message description',
            contains(
              'Unexpected error: FileSystemException: Disk write failed',
            ),
          ),
        ),
      );
    });
  });
}
