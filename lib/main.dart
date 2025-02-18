import 'package:flutter/material.dart';
import 'package:absensi_app/views/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi_app/utils/device_utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import './views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await initializeDateFormatting('id_ID', null);

  // Cek apakah deviceId sudah ada, jika belum ambil dari DeviceUtils dan simpan
  String? deviceId = prefs.getString("deviceId");
  if (deviceId == null) {
    deviceId = await DeviceUtils.getDeviceId();
    await prefs.setString("deviceId", deviceId);
  }

  bool isLoggedIn = prefs.getString("token") != null;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Absensi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}


