import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceUtils {
  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Device ID untuk Android
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "Unknown"; // Device ID untuk iOS
    }
    return "Unknown Device";
  }
}
