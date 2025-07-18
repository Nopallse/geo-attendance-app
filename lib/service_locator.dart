import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'data/api/api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/office_repository.dart';
import 'data/repositories/leave_repository.dart';
import 'data/repositories/late_arrival_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/office_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/late_arrival_provider.dart';
import 'providers/notification_provider.dart';
import 'services/late_arrival_service.dart';
import 'data/api/services/fcm_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<Logger>(Logger());
  getIt.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  getIt.registerSingleton<FCMService>(
    FCMService(getIt<FirebaseMessaging>(), getIt<SharedPreferences>()),
  );

  // Core
  getIt.registerSingleton<ApiService>(ApiService());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(),
  );
  getIt.registerSingleton<AttendanceRepository>(
    AttendanceRepositoryImpl(),
  );
  getIt.registerSingleton<OfficeRepository>(
    OfficeRepositoryImpl(),
  );
  getIt.registerSingleton<LeaveRepository>(
    LeaveRepositoryImpl(),
  );
  getIt.registerSingleton<LateArrivalRepository>(
    LateArrivalRepository(),
  );
  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(getIt<ApiService>()),
  );

  // Services
  getIt.registerSingleton<LateArrivalService>(
    LateArrivalService(repository: getIt<LateArrivalRepository>()),
  );

  // Providers
  getIt.registerFactory<AuthProvider>(
    () => AuthProvider(
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<AttendanceProvider>(
    () => AttendanceProvider(
      attendanceRepository: getIt<AttendanceRepository>(),
    ),
  );
  getIt.registerFactory<OfficeProvider>(
    () => OfficeProvider(
      officeRepository: getIt<OfficeRepository>(),
    ),
  );
  getIt.registerFactory<LeaveProvider>(
    () => LeaveProvider(getIt<LeaveRepository>()),
  );
  getIt.registerFactory<NotificationProvider>(
    () => NotificationProvider(
      getIt<NotificationRepository>(),
    ),
  );
  getIt.registerFactory<LateArrivalProvider>(
    () => LateArrivalProvider(
      repository: getIt<LateArrivalRepository>(),
    ),
  );
}