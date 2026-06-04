import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/data/models/organization_models/organization_request.dart';
import 'package:street_team/data/repositories/organization_repository.dart';
import 'package:street_team/data/services/organization_service.dart';

// Define Mocks
class MockOrganizationService extends Mock implements OrganizationService {}

class MockOrganizationRequestModel extends Mock
    implements OrganizationRequestModel {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  late MockOrganizationService mockService;
  late OrganizationRepository repository;
  late MockOrganizationRequestModel mockModel;

  setUp(() {
    mockService = MockOrganizationService();
    repository = OrganizationRepository(service: mockService);
    mockModel = MockOrganizationRequestModel();
  });

  group('submitOrganization', () {
    test(
      'returns ApiResponse.success wrapping the response on successful submission',
      () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(201);

        when(
          () => mockService.submitOrganization(mockModel),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.submitOrganization(mockModel);

        expect(result.success, isTrue);
        expect(result.data, mockResponse);
        verify(() => mockService.submitOrganization(mockModel)).called(1);
      },
    );

    test(
      'returns ApiResponse.failure and strips "Exception: " prefix on failure',
      () async {
        when(
          () => mockService.submitOrganization(mockModel),
        ).thenThrow(Exception('Exception: Server validation failed'));

        final result = await repository.submitOrganization(mockModel);

        expect(result.success, isFalse);
        expect(result.message, 'Server validation failed');
        verify(() => mockService.submitOrganization(mockModel)).called(1);
      },
    );

    test(
      'returns ApiResponse.failure with raw message if "Exception: " prefix is not present',
      () async {
        when(
          () => mockService.submitOrganization(mockModel),
        ).thenThrow('Unexpected raw string error');

        final result = await repository.submitOrganization(mockModel);

        expect(result.success, isFalse);
        expect(result.message, 'Unexpected raw string error');
      },
    );
  });

  group('updateOrganization', () {
    const orgId = 'org-789';

    test(
      'returns ApiResponse.success wrapping the response on successful update',
      () async {
        final mockResponse = MockResponse();
        when(() => mockResponse.statusCode).thenReturn(200);

        when(
          () => mockService.updateOrganization(orgId, mockModel),
        ).thenAnswer((_) async => mockResponse);

        final result = await repository.updateOrganization(orgId, mockModel);

        expect(result.success, isTrue);
        expect(result.data, mockResponse);
        verify(
          () => mockService.updateOrganization(orgId, mockModel),
        ).called(1);
      },
    );

    test(
      'returns ApiResponse.failure and cleans up message on exception',
      () async {
        when(() => mockService.updateOrganization(orgId, mockModel)).thenThrow(
          Exception(
            'Exception: Missing permissions to modify this organization',
          ),
        );

        final result = await repository.updateOrganization(orgId, mockModel);

        expect(result.success, isFalse);
        expect(
          result.message,
          'Missing permissions to modify this organization',
        );
        verify(
          () => mockService.updateOrganization(orgId, mockModel),
        ).called(1);
      },
    );
  });
}
