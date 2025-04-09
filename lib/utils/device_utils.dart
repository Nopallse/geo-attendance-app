import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  static Future<String> getDeviceId() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;

    if (allInfo.containsKey('identifierForVendor')) {
      return allInfo['identifierForVendor'];
    } else if (allInfo.containsKey('androidId')) {
      return allInfo['androidId'];
    } else {
      return 'Unknown Device ID';
    }
  }

  static Future<String> getDeviceModel() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;

    if (allInfo.containsKey('model')) {
      return allInfo['model'];
    } else {
      return 'Unknown Device Model';
    }
  }

  static Future<String> getOSVersion() async {
    final deviceInfo = await _deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;

    if (allInfo.containsKey('systemVersion')) {
      return allInfo['systemVersion'];
    } else if (allInfo.containsKey('version.release')) {
      return allInfo['version.release'];
    } else {
      return 'Unknown OS Version';
    }
  }
}