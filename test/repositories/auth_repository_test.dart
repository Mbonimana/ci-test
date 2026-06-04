import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/network/status_codes.dart';
import 'package:street_team/data/repositories/auth/auth_repository.dart';
import 'package:street_team/data/services/auth/auth_service.dart';
import 'package:street_team/data/services/auth/storage/auth_storage_keys.dart';

// Define Mock classes
class MockAuthService extends Mock implements AuthService {}

class MockResponse extends Mock implements Response<dynamic> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late AuthRepo authRepo;
  late Map<String, String> simulatedStorage;

  const email = 'test@street-team.com';
  const password = 'securePassword123';
  const murugoToken = 'murugo_access_token_abc';
  const streetTeamToken = 'street_team_access_token_xyz';
  const userIdentifier = '9999';

  final userDataMock = {
    'murugo_user_id': userIdentifier,
    'name': 'John Doe',
    'email': email,
  };

  setUp(() {
    mockAuthService = MockAuthService();
    authRepo = AuthRepo(service: mockAuthService);
    simulatedStorage = {};

    // Mock secure storage channel used by flutter_secure_storage
    const secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (
          MethodCall methodCall,
        ) async {
          final args = methodCall.arguments as Map<dynamic, dynamic>?;
          switch (methodCall.method) {
            case 'write':
              if (args != null) {
                simulatedStorage[args['key'] as String] =
                    args['value'] as String;
              }
              return null;
            case 'read':
              if (args != null) {
                return simulatedStorage[args['key'] as String];
              }
              return null;
            case 'deleteAll':
            case 'clear':
              simulatedStorage.clear();
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    const secureStorageChannel = MethodChannel(
      'plugins.it_nomads.com/flutter_secure_storage',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
  });

  group('login', () {
    test(
      'succeeds through sequential steps and saves sessions on successful auth flows',
      () async {
        final step1Response = MockResponse();
        when(() => step1Response.statusCode).thenReturn(StatusCodes.success);
        when(
          () => step1Response.data,
        ).thenReturn({'access_token': murugoToken});

        final step2Response = MockResponse();
        when(() => step2Response.statusCode).thenReturn(StatusCodes.success);
        when(() => step2Response.data).thenReturn(userDataMock);

        final step3Response = MockResponse();
        when(() => step3Response.statusCode).thenReturn(StatusCodes.success);
        when(
          () => step3Response.data,
        ).thenReturn({'access_token': streetTeamToken});

        // Stub sequentially executed methods
        when(
          () => mockAuthService.authenticateMurugo(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => step1Response);
        when(
          () => mockAuthService.getUserInfo(accessToken: murugoToken),
        ).thenAnswer((_) async => step2Response);
        when(
          () => mockAuthService.loginStreetTeam(userIdentifier: userIdentifier),
        ).thenAnswer((_) async => step3Response);

        final response = await authRepo.login(email: email, password: password);

        expect(response.success, isTrue);

        // Verify correct values were saved in local storage
        expect(
          simulatedStorage[AuthStorageKeys.murugoAccessToken],
          murugoToken,
        );
        expect(
          simulatedStorage[AuthStorageKeys.streetTeamAccessToken],
          streetTeamToken,
        );
        expect(
          simulatedStorage[AuthStorageKeys.userIdentifier],
          userIdentifier,
        );
        expect(
          jsonDecode(simulatedStorage[AuthStorageKeys.userProfile]!)['name'],
          'John Doe',
        );
      },
    );

    test('returns failure early if Step 1 (Murugo Auth) fails', () async {
      final step1Response = MockResponse();
      when(() => step1Response.statusCode).thenReturn(401);

      when(
        () => mockAuthService.authenticateMurugo(
          email: email,
          password: password,
        ),
      ).thenAnswer((_) async => step1Response);

      final response = await authRepo.login(email: email, password: password);

      expect(response.success, isFalse);
      expect(response.message, 'Murugo authentication failed');
      verifyNever(
        () =>
            mockAuthService.getUserInfo(accessToken: any(named: 'accessToken')),
      );
    });

    test('returns custom failure message during connection timeouts', () async {
      when(
        () => mockAuthService.authenticateMurugo(
          email: email,
          password: password,
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final response = await authRepo.login(email: email, password: password);

      expect(response.success, isFalse);
      expect(response.message, 'Please check your internet connection.');
    });

    test(
      'extracts detailed server messages when DioException occurs',
      () async {
        when(
          () => mockAuthService.authenticateMurugo(
            email: email,
            password: password,
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            response: Response(
              requestOptions: RequestOptions(),
              data: {'error_description': 'Murugo password expired'},
            ),
          ),
        );

        final response = await authRepo.login(email: email, password: password);

        expect(response.success, isFalse);
        expect(response.message, 'Murugo password expired');
      },
    );
  });

  group('isLoggedIn', () {
    test('returns false when no access token is stored', () async {
      final loggedIn = await authRepo.isLoggedIn();
      expect(loggedIn, isFalse);
    });

    test(
      'returns true and decodes profile when valid credentials exist',
      () async {
        simulatedStorage[AuthStorageKeys.streetTeamAccessToken] =
            streetTeamToken;
        simulatedStorage[AuthStorageKeys.userProfile] = jsonEncode(
          userDataMock,
        );

        final loggedIn = await authRepo.isLoggedIn();

        expect(loggedIn, isTrue);
      },
    );
  });

  group('getters & actions', () {
    test('getAccessToken retrieves correct value', () async {
      simulatedStorage[AuthStorageKeys.streetTeamAccessToken] = 'sample_token';
      final token = await authRepo.getAccessToken();
      expect(token, 'sample_token');
    });

    test('getUserIdentifier retrieves correct identifier value', () async {
      simulatedStorage[AuthStorageKeys.userIdentifier] = 'user_99';
      final id = await authRepo.getUserIdentifier();
      expect(id, 'user_99');
    });

    test('logout clears storage completely', () async {
      simulatedStorage['some_key'] = 'some_value';

      await authRepo.logout();

      expect(simulatedStorage.isEmpty, isTrue);
    });
  });
}
