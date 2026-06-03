import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:street_team/core/network/response.dart';
import 'package:street_team/data/repositories/auth/auth_repository.dart';
import 'package:street_team/presentation/providers/auth/auth_provider.dart';

// mocks
class MockAuthRepo extends Mock implements AuthRepo {}

void main() {
  late MockAuthRepo mockAuthRepo;
  late AuthNotifier authNotifier;

  const email = 'test@street-team.com';
  const password = 'securePassword123';

  setUp(() {
    mockAuthRepo = MockAuthRepo();
  });

  group('Initialization', () {
    test(
      'calls checkSession and initializes state to true if session is active',
      () async {
        // Stub isLoggedIn before notifier instantiation
        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);

        authNotifier = AuthNotifier(repo: mockAuthRepo);

        // Await pending microtasks so checkSession resolves
        await Future<void>.delayed(Duration.zero);

        expect(authNotifier.state, isTrue);
        verify(() => mockAuthRepo.isLoggedIn()).called(1);
      },
    );

    test(
      'calls checkSession and initializes state to false if session is inactive',
      () async {
        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => false);

        authNotifier = AuthNotifier(repo: mockAuthRepo);

        await Future<void>.delayed(Duration.zero);

        expect(authNotifier.state, isFalse);
      },
    );
  });

  group('login', () {
    test(
      'updates state to true and returns successful ApiResponse on successful login',
      () async {
        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => false);
        authNotifier = AuthNotifier(repo: mockAuthRepo);
        await Future<void>.delayed(Duration.zero); // resolve init check

        final successResponse = ApiResponse<void>.success(null);
        when(
          () => mockAuthRepo.login(email: email, password: password),
        ).thenAnswer((_) async => successResponse);

        final result = await authNotifier.login(
          email: email,
          password: password,
        );

        expect(result.success, isTrue);
        expect(authNotifier.state, isTrue);
        verify(
          () => mockAuthRepo.login(email: email, password: password),
        ).called(1);
      },
    );

    test(
      'retains state as false and returns failed ApiResponse on login failure',
      () async {
        when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => false);
        authNotifier = AuthNotifier(repo: mockAuthRepo);
        await Future<void>.delayed(Duration.zero);

        final failureResponse = ApiResponse<void>.failure(
          'Invalid credentials',
        );
        when(
          () => mockAuthRepo.login(email: email, password: password),
        ).thenAnswer((_) async => failureResponse);

        final result = await authNotifier.login(
          email: email,
          password: password,
        );

        expect(result.success, isFalse);
        expect(result.message, 'Invalid credentials');
        expect(authNotifier.state, isFalse);
      },
    );
  });

  group('logout', () {
    test('calls repository logout and resets state to false', () async {
      // Initialize with an active session (state = true)
      when(() => mockAuthRepo.isLoggedIn()).thenAnswer((_) async => true);
      authNotifier = AuthNotifier(repo: mockAuthRepo);
      await Future<void>.delayed(Duration.zero);
      expect(authNotifier.state, isTrue);

      when(() => mockAuthRepo.logout()).thenAnswer((_) async => {});

      await authNotifier.logout();

      expect(authNotifier.state, isFalse);
      verify(() => mockAuthRepo.logout()).called(1);
    });
  });
}
