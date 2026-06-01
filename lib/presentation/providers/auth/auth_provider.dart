import 'package:flutter_riverpod/legacy.dart';
import 'package:street_team/core/network/response.dart';
import 'package:street_team/data/repositories/auth/auth_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false) {
    checkSession();
  }

  final AuthRepo _repo = AuthRepo();

  Future<void> checkSession() async {
    state = await _repo.isLoggedIn();
  }

  Future<ApiResponse<void>> login({
    required String email,
    required String password,
  }) async {
    final response = await _repo.login(email: email, password: password);

    if (response.success) {
      state = true;
    }

    return response; //  response to UI
  }

  Future<void> logout() async {
    await _repo.logout();
    state = false;
  }
}
