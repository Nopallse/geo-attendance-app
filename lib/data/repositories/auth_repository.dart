import '../models/user_model.dart';
import '../api/services/auth_service.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> getUserProfile();
  Future<void> logout();
  Future<bool> isLoggedIn();
}


class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _authService.getUserProfile();
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }
}