import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../api/services/attendance_service.dart';


abstract class AttendanceRepository {
  Future<Map<String, dynamic>> createAttendance(bool isCheckIn, double latitude, double longitude);
  Future<Map<String, dynamic>> getTodayAttendance();
  Future<Map<String, dynamic>> getAttendanceHistory({int page, int limit});
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceService _attendanceService = AttendanceService();

  @override
  Future<Map<String, dynamic>> createAttendance(bool isCheckIn, double latitude, double longitude) async {
    return await _attendanceService.createAttendance(isCheckIn, latitude, longitude);
  }

  @override
  Future<Map<String, dynamic>> getTodayAttendance() async {
    return await _attendanceService.getTodayAttendance();
  }

  @override
  Future<Map<String, dynamic>> getAttendanceHistory({int page = 1, int limit = 10}) async {
    return await _attendanceService.getAttendanceHistory(page: page, limit: limit);
  }
}