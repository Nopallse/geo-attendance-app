import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  static const String tokenKey = "token";
  static const String deviceIdKey = "device_id";
  static const String userDataKey = "user_data";

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

  // Save user data (as JSON string)
  static Future<bool> saveUserData(String userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userDataKey, userData);
  }

  // Get user data
  static Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userDataKey);
  }

  // Remove user data
  static Future<bool> removeUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(userDataKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all saved data (for logout)
  static Future<bool> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Keep device ID but clear everything else
    String? deviceId = prefs.getString(deviceIdKey);
    await prefs.clear();

    // If device ID existed, restore it
    if (deviceId != null) {
      await prefs.setString(deviceIdKey, deviceId);
    }

    return true;
  }
}