import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class KantorService {
  final String baseUrl = "https://polite-helping-moray.ngrok-free.app";
  final logger = Logger();

  Future<Map<String, dynamic>> getKantor() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      logger.d("Token absen: $token");
      String? deviceId = prefs.getString("deviceId") ?? "";
      if (token == null) {
        return {"success": false, "message": "Token tidak ditemukan"};
      }

      final url = Uri.parse('$baseUrl/absen/kantor');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Device_Id": deviceId,
          "Authorization": "Bearer $token",
        },
      );


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.d("Response Body<<<<<<<<<: ${data}");

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

  
}