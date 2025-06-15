import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/attendance_model.dart';
import '../api/services/attendance_service.dart';


abstract class AttendanceRepository {
  Future<Map<String, dynamic>> createAttendance(bool isCheckIn, double latitude, double longitude, int lokasi_id);
  Future<Map<String, dynamic>> getTodayAttendance();
  Future<Map<String, dynamic>> getAttendanceHistory({int page, int limit});
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceService _attendanceService = AttendanceService();

  @override
  Future<Map<String, dynamic>> createAttendance(bool isCheckIn, double latitude, double longitude, lokasi_id) async {
    return await _attendanceService.createAttendance(isCheckIn, latitude, longitude, lokasi_id);
  }

  @override
  Future<Map<String, dynamic>> getTodayAttendance() async {
    final response = await _attendanceService.getTodayAttendance();
    final attendanceData = response['data'];

    print("Fetching today's attendance: $attendanceData");
    return attendanceData;
  }

  @override
  Future<Map<String, dynamic>> getAttendanceHistory({int page = 1, int limit = 10}) async {
    return await _attendanceService.getAttendanceHistory(page: page, limit: limit);
  }
}