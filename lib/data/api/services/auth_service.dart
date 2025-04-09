import '../../api/api_service.dart';
import '../../api/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        body: {"email": email, "password": password},
        requiresAuth: false,
      );

      if (response['success']) {
        // Save token to SharedPreferences on successful login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", response['data']["token"]);
      }

      return response;
    } catch (e) {
      return {"success": false, "message": "Login failed: $e"};
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      return await _apiService.get(ApiEndpoints.userProfile);
    } catch (e) {
      return {"success": false, "message": "Failed to get user profile: $e"};
    }
  }

  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("token");
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("token") != null;
    } catch (e) {
      return false;
    }
  }
}