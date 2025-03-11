import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthService {
  final String baseUrl = "https://polite-helping-moray.ngrok-free.app"; // Ganti dengan URL backend
  final logger = Logger();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("deviceId") ?? ""; 
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Device_Id": deviceId,
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        return {"success": true};
      } else {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": errorData["error"]};
      }
    } catch (e) {
      logger.d("Error: \$e");
      return {"success": false, "message": "Terjadi kesalahan, coba lagi"};
    }
  }



  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("token"); // Hapus token saat logout
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") != null;
  }

  Future<Map<String, dynamic>> getUserData() async {
    final url = Uri.parse('$baseUrl/me');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? deviceId = prefs.getString("deviceId") ?? "";

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "device_id": deviceId,
        },
      );

      logger.d("Response Status: \${response.statusCode}");
      logger.d("Response Body: \${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};

      } else {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": errorData["error"]};

      }
    } catch (e) {
      logger.d("Error: \$e");
      return {"success": false, "message": "Terjadi kesalahan saat mengambil riwayat absensi"};

    }
  }
}
