import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:absensi_app/utils/device_utils.dart';
import 'package:absensi_app/utils/shared_prefs_utils.dart';
import 'package:absensi_app/screens/login/login_page.dart';
import 'package:absensi_app/screens/home_page.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:absensi_app/providers/attendance_provider.dart';
import 'package:absensi_app/providers/office_provider.dart';
import 'package:absensi_app/data/repositories/auth_repository.dart';
import 'package:absensi_app/data/repositories/attendance_repository.dart';
import 'package:absensi_app/data/repositories/office_repository.dart';
import 'service_locator.dart';

Future<void> main() async {
  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Initialize service locator
  setupServiceLocator();

  // Ensure device ID is initialized and stored in SharedPreferences
  try {
    String deviceId = await DeviceUtils.getDeviceId();
    logger.d("Device ID in main: $deviceId");
  } catch (e) {
    logger.e("Error initializing device ID: $e");
  }

  // Check login status from SharedPreferences
  bool isLoggedIn = await SharedPrefsUtils.isLoggedIn();
  logger.d("User login status: $isLoggedIn");

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authRepository: serviceLocator<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => AttendanceProvider(
            attendanceRepository: serviceLocator<AttendanceRepository>(),
          ),
        ),
        ChangeNotifierProvider<OfficeProvider>(
          create: (_) => OfficeProvider(
            officeRepository: serviceLocator<OfficeRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aplikasi Absensi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: isLoggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }
}