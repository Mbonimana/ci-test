import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/data/models/location_models/location_request_model.dart';
import 'package:street_team/data/models/location_models/location_response.dart';
import 'package:street_team/data/repositories/location_repository.dart';
import 'package:street_team/data/services/location_service.dart';

class MockLocationService extends Mock implements LocationService {}

class MockLocationModel extends Mock implements LocationModel {}

class MockLocationResponse extends Mock implements LocationResponse {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late MockLocationService mockLocationService;
  late LocationRepository locationRepository;

  setUp(() {
    mockLocationService = MockLocationService();
    locationRepository = LocationRepository(service: mockLocationService);
  });

  group('getLocationById', () {
    const id = 'loc-123';

    test(
      'delegates call directly to LocationService.getLocationById',
      () async {
        final mockModel = MockLocationModel();
        when(
          () => mockLocationService.getLocationById(id),
        ).thenAnswer((_) async => mockModel);

        final result = await locationRepository.getLocationById(id);

        expect(result, mockModel);
        verify(() => mockLocationService.getLocationById(id)).called(1);
      },
    );
  });

  group('submitLocation', () {
    test('delegates call directly to LocationService.submitLocation', () async {
      final mockModel = MockLocationModel();
      final mockResponse = MockResponse();

      when(
        () => mockLocationService.submitLocation(mockModel),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationRepository.submitLocation(mockModel);

      expect(result, mockResponse);
      verify(() => mockLocationService.submitLocation(mockModel)).called(1);
    });
  });

  group('updateLocation', () {
    const id = 'loc-456';

    test('delegates call directly to LocationService.updateLocation', () async {
      final mockModel = MockLocationModel();
      final mockResponse = MockResponse();

      when(
        () => mockLocationService.updateLocation(id, mockModel),
      ).thenAnswer((_) async => mockResponse);

      final result = await locationRepository.updateLocation(id, mockModel);

      expect(result, mockResponse);
      verify(() => mockLocationService.updateLocation(id, mockModel)).called(1);
    });
  });

  group('searchLocations', () {
    const query = 'central park';

    test(
      'delegates call directly to LocationService.searchLocations',
      () async {
        final mockResponseList = [MockLocationResponse()];

        when(
          () => mockLocationService.searchLocations(query),
        ).thenAnswer((_) async => mockResponseList);

        final result = await locationRepository.searchLocations(query);

        expect(result, mockResponseList);
        expect(result.length, 1);
        verify(() => mockLocationService.searchLocations(query)).called(1);
      },
    );
  });

  group('fetchLocationsForMap', () {
    test(
      'delegates call to LocationService.getPaginatedLocations with page 1',
      () async {
        final mockResponseList = [MockLocationResponse()];

        when(
          () => mockLocationService.getPaginatedLocations(page: 1),
        ).thenAnswer((_) async => mockResponseList);

        final result = await locationRepository.fetchLocationsForMap();

        expect(result, mockResponseList);
        verify(
          () => mockLocationService.getPaginatedLocations(page: 1),
        ).called(1);
      },
    );
  });

  group('fetchMoreLocations', () {
    const page = 3;

    test(
      'delegates call to LocationService.getDiscoveryResults with correct page',
      () async {
        final mockResponseList = [MockLocationResponse()];

        when(
          () => mockLocationService.getDiscoveryResults(page),
        ).thenAnswer((_) async => mockResponseList);

        final result = await locationRepository.fetchMoreLocations(page);

        expect(result, mockResponseList);
        verify(() => mockLocationService.getDiscoveryResults(page)).called(1);
      },
    );
  });
}
