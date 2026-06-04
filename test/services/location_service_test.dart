import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/services/location_service.dart';

class MockDio extends Mock implements Dio {}

class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late LocationService locationService;

  // Standard dummy models for tests
  final testLocationModel = LocationModel(
    name: 'Test Station',
    physicalAddress: '123 Test St',
    shortName: 'TS',
    nickname: 'Testy',
    latitude: 1.234,
    longitude: 5.678,
    types: [1, 2],
    submitterServer: 'server_1',
    submitterAtName: 'Submitter',
    userLocation: {},
  );

  final testLocationResponseJson = {
    'id': 'loc-123',
    'name': 'Test Response Location',
  };

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    locationService = LocationService(mockDio);

    const MethodChannel secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'read') {
            return 'mock_access_token';
          }
          if (methodCall.method == 'deleteAll') {
            return null;
          }
          return null;
        });
  });

  group('submitLocation', () {
    test('submits successfully with authorization token', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(200);

      when(
        () => mockDio.post<dynamic>(
          Endpoints.submitLocation,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationService.submitLocation(testLocationModel);

      expect(result.statusCode, 200);
      verify(
        () => mockDio.post<dynamic>(
          Endpoints.submitLocation,
          data: testLocationModel.toJson(),
          options: any(
            named: 'options',
            that: isA<Options>().having(
              (o) => o.headers?['Authorization'],
              'Authorization Header',
              'Bearer mock_access_token',
            ),
          ),
        ),
      ).called(1);
    });

    test('correctly maps connection timeout exception', () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: Endpoints.submitLocation),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => locationService.submitLocation(testLocationModel),
        throwsA(equals(" Check your internet connection and try again.")),
      );
    });
  });

  group('updateLocation', () {
    const id = 'loc-id';

    test('sends PUT request and returns response', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(200);

      when(
        () => mockDio.put<dynamic>(
          Endpoints.updateLocation(id),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationService.updateLocation(
        id,
        testLocationModel,
      );

      expect(result.statusCode, 200);
      verify(
        () => mockDio.put<dynamic>(
          Endpoints.updateLocation(id),
          data: testLocationModel.toJson(),
        ),
      ).called(1);
    });
  });

  group('searchLocations', () {
    const query = 'central';

    test('returns structured List of LocationResponse', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.data).thenReturn([testLocationResponseJson]);

      when(
        () => mockDio.post<dynamic>(
          Endpoints.searchLocation,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationService.searchLocations(query);

      expect(result, isA<List<LocationResponse>>());
      expect(result.length, 1);
      expect(result.first.name, 'Test Response Location');
    });
  });

  group('getLocationById', () {
    const id = '123';

    test('returns LocationModel upon parsing endpoint body', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.data).thenReturn({
        'data': {
          'name': 'Detail Station',
          'physical_address': '456 Detail Rd',
          'short_name': 'DS',
          'nickname': 'Detail',
          'latitude': -1.2,
          'longitude': 36.8,
          'types': [3],
          'submitter_server': 'server_2',
          'submitter_at_name': 'Submitter Two',
          'user_location': null,
        },
      });

      when(
        () => mockDio.get<dynamic>(Endpoints.getLocationById(id)),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationService.getLocationById(id);

      expect(result, isA<LocationModel>());
      expect(result.name, 'Detail Station');
      expect(result.latitude, -1.2);
    });
  });

  group('getPaginatedLocations', () {
    test('requests correct endpoint with query parameters', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.data).thenReturn({
        'data': [testLocationResponseJson],
      });

      when(
        () => mockDio.get<dynamic>('${Endpoints.getLocations}&page=2'),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationService.getPaginatedLocations(page: 2);

      expect(result, isA<List<LocationResponse>>());
      expect(result.length, 1);
    });

    test(
      'extracts custom message when server returns an error response',
      () async {
        final errorResponse = Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Invalid page requested'},
        );

        when(() => mockDio.get<dynamic>(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            response: errorResponse,
          ),
        );

        expect(
          () => locationService.getPaginatedLocations(page: 10),
          throwsA(equals('Invalid page requested')),
        );
      },
    );
  });

  group('getDiscoveryResults', () {
    test('proxies calls directly to getPaginatedLocations', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.data).thenReturn({
        'data': [testLocationResponseJson],
      });

      when(
        () => mockDio.get<dynamic>('${Endpoints.getLocations}&page=3'),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationService.getDiscoveryResults(3);

      expect(result.length, 1);
    });
  });
}
