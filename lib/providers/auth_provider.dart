import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  // Dependency injection through constructor
  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;
  String? get successMessage => _successMessage;

  // Initialize provider - check if user is logged in
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool loggedIn = await _authRepository.isLoggedIn();
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
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
    final result = await _authRepository.login(username, password);

    if (result['success']) {
      // Mengambil pesan sukses dari respons JSON
      _successMessage = result['message'] ?? 'Login berhasil';
      await getUserProfile();
      return true;
    } else {
      // Mengambil pesan error dari respons JSON
      _errorMessage = result['message'] ?? 'Login gagal';
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
      final result = await _authRepository.getUserProfile();

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
      await _authRepository.logout();
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