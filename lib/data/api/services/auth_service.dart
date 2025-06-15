import 'dart:convert';
import '../../api/api_service.dart';
import '../../api/endpoints.dart';
import '../../../utils/shared_prefs_utils.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        body: {"username": username, "password": password},
        requiresAuth: false,
      );

      if (response['success']) {
        // Jika user profile data disertakan dalam response, simpan
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
      // Coba ambil dari SharedPreferences
      String? userData = await SharedPrefsUtils.getUserData();
      if (userData != null) {
        return {"success": true, "data": jsonDecode(userData)};
      }

      // Jika tidak tersedia, ambil dari API
      final response = await _apiService.get(ApiEndpoints.userProfile);

      // Jika berhasil, simpan ke SharedPreferences untuk penggunaan selanjutnya
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
      // Hapus semua data terkait pengguna tetapi simpan device ID
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