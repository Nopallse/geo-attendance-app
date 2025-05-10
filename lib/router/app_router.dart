// lib/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:absensi_app/screens/absensi/absensi_page.dart';
import 'package:absensi_app/screens/login/login_page.dart';
import 'package:absensi_app/screens/splash/splash_screen.dart';
import 'package:absensi_app/screens/home_page.dart';
import 'package:absensi_app/screens/dashboard/dashboard_page.dart';
import 'package:absensi_app/screens/riwayat/riwayat_page.dart';
import 'package:absensi_app/screens/notification/notification_page.dart';
import 'package:absensi_app/screens/profile/profile_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      // Splash screen route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Absensi route (accessed via FAB)
      GoRoute(
        path: '/absensi',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AbsensiPage(),
      ),

      // Shell route for main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          // Dashboard route
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // Riwayat route
          GoRoute(
            path: '/riwayat',
            builder: (context, state) => const RiwayatPage(),
          ),

          // Notification route
          GoRoute(
            path: '/notification',
            builder: (context, state) => const NotificationPage(),
          ),

          // Profile route
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}