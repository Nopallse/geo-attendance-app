import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static const String tokenKey = "token";
  static const String deviceIdKey = "deviceId";

  // Get token
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Save token
  static Future<bool> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(tokenKey, token);
  }

  // Remove token
  static Future<bool> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(tokenKey);
  }

  // Get device ID
  static Future<String?> getDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(deviceIdKey);
  }

  // Save device ID
  static Future<bool> saveDeviceId(String deviceId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(deviceIdKey, deviceId);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}