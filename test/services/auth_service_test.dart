import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/config/env_config.dart';
import 'package:street_team/core/network/endpoints.dart';
import 'package:street_team/data/services/auth/auth_service.dart';

// Create Mock Classes
class MockDio extends Mock implements Dio {}

class MockResponse<T> extends Mock implements Response<T> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorageChannel, (MethodCall call) async {
        switch (call.method) {
          case 'deleteAll':
            return null;
          case 'write':
            return null;
          case 'read':
            return null;
          default:
            return null;
        }
      });
  late MockDio mockDio;
  late AuthService authService;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(dio: mockDio);
  });

  group('authenticateMurugo', () {
    const email = 'test@example.com';
    const password = 'password123';
    final url = '${EnvConfig.murugoBaseUrl}${Endpoints.murugoToken}';

    test('returns Response on successful authentication', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(
        () => mockResponse.data,
      ).thenReturn({'access_token': 'murugo_token'});

      when(
        () => mockDio.post<dynamic>(
          url,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.authenticateMurugo(
        email: email,
        password: password,
      );

      expect(result.statusCode, 200);
      expect(result.data['access_token'], 'murugo_token');

      // Verify that the post request was sent with the correct structure
      verify(
        () => mockDio.post<dynamic>(
          url,
          data: {
            'grant_type': 'password',
            'client_id': EnvConfig.murugoClientId,
            'client_secret': EnvConfig.murugoClientSecret,
            'username': email,
            'password': password,
          },
          options: any(named: 'options'),
        ),
      ).called(1);
    });

    test(
      'throws customized DioException when response contains error message',
      () async {
        final dioException = DioException(
          requestOptions: RequestOptions(path: url),
          response: Response(
            requestOptions: RequestOptions(path: url),
            statusCode: 400,
            data: {'error_description': 'Invalid credentials'},
          ),
        );

        when(
          () => mockDio.post<dynamic>(
            url,
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(dioException);

        expect(
          () =>
              authService.authenticateMurugo(email: email, password: password),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error message',
              'Invalid credentials',
            ),
          ),
        );
      },
    );
  });

  group('getUserInfo', () {
    const accessToken = 'valid_token';
    final url = '${EnvConfig.murugoBaseUrl}${Endpoints.thirdPartyMe}';

    test('returns user information response on success', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'name': 'John Doe'});

      when(
        () => mockDio.get<dynamic>(url, options: any(named: 'options')),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.getUserInfo(accessToken: accessToken);

      expect(result.statusCode, 200);
      expect(result.data['name'], 'John Doe');
    });

    test('rethrows DioException on failure', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: url),
        message: 'Network connection failed',
      );

      when(
        () => mockDio.get<dynamic>(url, options: any(named: 'options')),
      ).thenThrow(dioException);

      expect(
        () => authService.getUserInfo(accessToken: accessToken),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('loginStreetTeam', () {
    const userIdentifier = 'user-123';
    final url = '${EnvConfig.baseUrl}${Endpoints.ccLogin}';

    test('returns success response when status code is 200 or 201', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(201);
      when(() => mockResponse.data).thenReturn({'status': 'logged_in'});

      when(
        () => mockDio.post<dynamic>(
          url,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.loginStreetTeam(
        userIdentifier: userIdentifier,
      );

      expect(result.statusCode, 201);
      expect(result.data['status'], 'logged_in');
    });

    test('throws DioException when status code is not 200/201', () async {
      final mockResponse = MockResponse<dynamic>();
      when(() => mockResponse.statusCode).thenReturn(400);
      when(
        () => mockResponse.requestOptions,
      ).thenReturn(RequestOptions(path: url));
      when(() => mockResponse.data).thenReturn('Bad Request');

      when(
        () => mockDio.post<dynamic>(
          url,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => authService.loginStreetTeam(userIdentifier: userIdentifier),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'exception type',
            DioExceptionType.badResponse,
          ),
        ),
      );
    });
  });

  group('logout', () {
    test('clears authorization headers successfully', () async {
      final mockHeaders = <String, dynamic>{
        'Authorization': 'Bearer token',
        'Accept': 'application/json',
      };
      final baseOptions = BaseOptions(headers: mockHeaders);

      when(() => mockDio.options).thenReturn(baseOptions);

      await authService.logout();

      // Verify header transformations
      expect(baseOptions.headers.containsKey('Authorization'), isFalse);
      expect(baseOptions.headers['Accept'], 'application/json');
      expect(baseOptions.headers['Content-Type'], 'application/json');
    });
  });
}
