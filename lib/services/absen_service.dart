import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AbsenService {
  final String baseUrl = "https://polite-helping-moray.ngrok-free.app";
  final logger = Logger();

  Future<Map<String, dynamic>> createAbsen(bool isMasuk, double latitude, double longitude) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      logger.d("Token absen: $token");
      String? deviceId = prefs.getString("deviceId") ?? "";
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final url = Uri.parse('$baseUrl/absen');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Device_Id": deviceId,
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "type": isMasuk ? "masuk" : "keluar",
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      logger.d("Response Body<<<<<<<<<: ${response.statusCode}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": errorData["error"]};
      }
    } catch (e) {
      logger.e("Error: $e");
      return {"success": false, "message": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<Map<String, dynamic>> getAbsenToday() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final url = Uri.parse('$baseUrl/absen/today');
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "device_id": prefs.getString("deviceId") ?? "",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d("Response Body get today: $data");
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": errorData["error"]};
      }
    } catch (e) {
      logger.e("Error: $e");
      return {"success": false, "message": "Terjadi kesalahan, coba lagi"};
    }
  }

  Future<Map<String, dynamic>> getAttendanceHistory({int page = 1, int limit = 10}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      String? deviceId = prefs.getString("deviceId") ?? "";

      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final url = Uri.parse('$baseUrl/absen/history?page=$page&limit=$limit');
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "device_id": deviceId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data};
      } else {
        final errorData = jsonDecode(response.body);
        return {"success": false, "message": errorData["error"]};
      }
    } catch (e) {
      logger.e("Error: $e");
      return {"success": false, "message": "Terjadi kesalahan saat mengambil riwayat absensi"};
    }
  }
}