import 'package:flutter/foundation.dart';
import '../data/api/services/auth_service.dart';
import '../data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // Initialize provider - check if user is logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool loggedIn = await _authService.isLoggedIn();
      if (loggedIn) {
        await getUserProfile();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (result['success']) {
        await getUserProfile();
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user profile
  Future<void> getUserProfile() async {
    try {
      final result = await _authService.getUserProfile();

      if (result['success']) {
        _user = User.fromJson(result['data']);
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}