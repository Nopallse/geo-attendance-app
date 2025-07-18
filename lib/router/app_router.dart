// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'package:absensi_app/screens/splash/splash_screen.dart';
import 'package:absensi_app/screens/login/login_page.dart';
import 'package:absensi_app/screens/home_page.dart';
import 'package:absensi_app/screens/dashboard/dashboard_page.dart';
import 'package:absensi_app/screens/riwayat/riwayat_page.dart';
import 'package:absensi_app/screens/notification/notification_page.dart';
import 'package:absensi_app/screens/profile/profile_page.dart';
import 'package:absensi_app/screens/absensi/absensi_page.dart';
import 'package:absensi_app/screens/leave/leave_form_page.dart';
import 'package:absensi_app/screens/leave/create_leave_form_page.dart';
import 'package:absensi_app/screens/leave/late_arrival_requests_page.dart';
import 'package:absensi_app/screens/leave/create_late_arrival_request_page.dart';
import 'package:absensi_app/utils/shared_prefs_utils.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final logger = Logger();

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Splash screen route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          // Dashboard tab
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),

          // Riwayat tab
          GoRoute(
            path: '/riwayat',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RiwayatPage(),
            ),
          ),

          // Notifications tab
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationPage(),
            ),
          ),

          // Profile tab
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // Absensi page (full screen modal)
      GoRoute(
        path: '/absensi',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AbsensiPage(),
      ),

      // Leave form page (full screen modal)
      GoRoute(
        path: '/leave',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeaveFormPage(),
      ),

      // Leave form page (full screen modal)
      GoRoute(
        path: '/leave-form',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateLeaveFormPage(),
      ),

      // Late arrival requests page (full screen modal)
      GoRoute(
        path: '/late-arrival-requests',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LateArrivalRequestsPage(),
      ),

      // Create late arrival request page (full screen modal)
      GoRoute(
        path: '/create-late-arrival-request',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateLateArrivalRequestPage(),
      ),

    ],
  );

  static Future<String?> _handleRedirect(BuildContext context, GoRouterState state) async {
    final isLoggedIn = await SharedPrefsUtils.isLoggedIn();
    final isGoingToLogin = state.matchedLocation == '/login';
    final isInitialSplash = state.matchedLocation == '/';

    if (isInitialSplash) {
      return null;
    }

    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    if (isLoggedIn && isGoingToLogin) {
      return '/dashboard';
    }

    return null;
  }
}