import 'package:chatting_app/Services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);
  // Repository receives AuthService dependency.

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    // This method forwards login request to AuthService.
    return await _authService.login(
      email: email,
      password: password,
    );
  }
}
