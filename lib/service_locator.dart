import 'package:get_it/get_it.dart';

import 'data/repositories/attendance_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/office_repository.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/office_provider.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  serviceLocator.registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(),
  );

  serviceLocator.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(),
  );

  serviceLocator.registerLazySingleton<OfficeRepository>(
        () => OfficeRepositoryImpl(),
  );

  // Providers
  serviceLocator.registerFactory<AttendanceProvider>(
        () => AttendanceProvider(
      attendanceRepository: serviceLocator<AttendanceRepository>(),
    ),
  );

  serviceLocator.registerFactory<AuthProvider>(
        () => AuthProvider(
      authRepository: serviceLocator<AuthRepository>(),
    ),
  );

  serviceLocator.registerFactory<OfficeProvider>(
        () => OfficeProvider(
      officeRepository: serviceLocator<OfficeRepository>(),
    ),
  );
}