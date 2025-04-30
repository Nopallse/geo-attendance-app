import 'dart:convert';
import '../../api/api_service.dart';
import '../../api/endpoints.dart';
import '../../../utils/shared_prefs_utils.dart';

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
        await SharedPrefsUtils.saveToken(response['data']["token"]);

        // If user profile data is included in the response, save it too
        if (response['data']["user"] != null) {
          await SharedPrefsUtils.saveUserData(jsonEncode(response['data']["user"]));
        }
      }

      return response;
    } catch (e) {
      return {"success": false, "message": "Login failed: $e"};
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      // First try to get from SharedPreferences
      String? userData = await SharedPrefsUtils.getUserData();
      if (userData != null) {
        return {"success": true, "data": jsonDecode(userData)};
      }

      // If not available, fetch from API
      final response = await _apiService.get(ApiEndpoints.userProfile);

      // If successful, save to SharedPreferences for future use
      if (response['success'] && response['data'] != null) {
        await SharedPrefsUtils.saveUserData(jsonEncode(response['data']));
      }

      return response;
    } catch (e) {
      return {"success": false, "message": "Failed to get user profile: $e"};
    }
  }

  Future<void> logout() async {
    try {
      // Clear all user-related data but keep device ID
      await SharedPrefsUtils.clearAllData();
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      return await SharedPrefsUtils.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}