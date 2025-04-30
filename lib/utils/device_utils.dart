import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

class DeviceUtils {
  static final Logger _logger = Logger();
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static const String _deviceIdKey = 'device_id';

  static Future<String> getDeviceId() async {
    // First check if we already have a stored device ID in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedDeviceId = prefs.getString(_deviceIdKey);

    if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
      _logger.d('Device ID found in SharedPreferences: $storedDeviceId');
      return storedDeviceId;
    }

    // If no stored ID, try to get device-specific ID
    try {
      final deviceInfo = await _deviceInfoPlugin.deviceInfo;
      String? deviceId = _getIdFromDeviceInfo(deviceInfo);

      if (deviceId != null && deviceId.isNotEmpty) {
        _logger.d('Generated device ID from device info: $deviceId');
        await prefs.setString(_deviceIdKey, deviceId);
        return deviceId;
      }
    } catch (e) {
      _logger.e('Error getting device info: $e');
    }

    // Fallback to UUID if we couldn't get a device-specific ID
    String uuidDeviceId = const Uuid().v4();
    _logger.d('Generated UUID as fallback device ID: $uuidDeviceId');

    // Save the UUID to SharedPreferences
    await prefs.setString(_deviceIdKey, uuidDeviceId);

    return uuidDeviceId;
  }

  // Helper method to extract ID from DeviceInfoPlugin based on platform
  static String? _getIdFromDeviceInfo(BaseDeviceInfo deviceInfo) {
    try {
      if (deviceInfo is AndroidDeviceInfo) {
        // For Android, use a combination of identifiers to create a unique ID
        return '${deviceInfo.id}_${deviceInfo.model}_${deviceInfo.brand}';
      } else if (deviceInfo is IosDeviceInfo) {
        // For iOS, use identifierForVendor if available
        return deviceInfo.identifierForVendor;
      }
    } catch (e) {
      _logger.e('Error extracting device ID: $e');
    }

    return null;
  }
}