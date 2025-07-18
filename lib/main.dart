// lib/main.dart
import 'package:absensi_app/data/api/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:absensi_app/utils/device_utils.dart';
import 'package:absensi_app/utils/shared_prefs_utils.dart';
import 'package:absensi_app/providers/auth_provider.dart';
import 'package:absensi_app/providers/attendance_provider.dart';
import 'package:absensi_app/providers/office_provider.dart';
import 'package:absensi_app/providers/leave_provider.dart';
import 'package:absensi_app/providers/late_arrival_provider.dart';
import 'package:absensi_app/providers/notification_provider.dart';
import 'package:absensi_app/router/app_router.dart';
import 'firebase_options.dart';
import 'service_locator.dart';

Future<void> main() async {
  final logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initializeNotifications();

  // Initialize service locator
  await setupServiceLocator();

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
  const MyApp({super.key, required bool isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (_) => getIt<AttendanceProvider>(),
        ),
        ChangeNotifierProvider<OfficeProvider>(
          create: (_) => getIt<OfficeProvider>(),
        ),
        ChangeNotifierProvider<LeaveProvider>(
          create: (_) => getIt<LeaveProvider>(),
        ),
        ChangeNotifierProvider<LateArrivalProvider>(
          create: (_) => getIt<LateArrivalProvider>(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => getIt<NotificationProvider>(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Aplikasi Absensi',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'), // Indonesian
          Locale('en', 'US'), // English (fallback)
        ],
        locale: const Locale('id', 'ID'),
        routerConfig: AppRouter.router,
      ),
    );
  }
}