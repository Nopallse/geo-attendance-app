import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:absensi_app/utils/device_utils.dart';
import 'package:absensi_app/screens/login/login_page.dart';
import 'package:absensi_app/screens/home_page.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:absensi_app/providers/attendance_provider.dart';
import 'package:absensi_app/providers/office_provider.dart';


Future<void> main() async {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => OfficeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aplikasi Absensi',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
