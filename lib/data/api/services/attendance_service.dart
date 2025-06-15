import '../../api/api_service.dart';
import '../../api/endpoints.dart';

class AttendanceService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createAttendance(bool isCheckIn, double latitude, double longitude, int lokasi_id) async {
    try {
      return await _apiService.post(
        ApiEndpoints.createAttendance,
        body: {
          "type": isCheckIn ? "masuk" : "keluar",
          "latitude": latitude,
          "longitude": longitude,
          "lokasi_id": lokasi_id
        },
      );
    } catch (e) {
      return {"success": false, "message": "Attendance creation failed: $e"};
    }
  }

  Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      return await _apiService.get(ApiEndpoints.todayAttendance);
    } catch (e) {
      return {"success": false, "message": "Failed to get today's attendance: $e"};
    }
  }

  Future<Map<String, dynamic>> getAttendanceHistory({int page = 1, int limit = 10}) async {
    try {
      return await _apiService.get(
        ApiEndpoints.attendanceHistory,
        queryParams: {
          "page": page.toString(),
          "limit": limit.toString(),
        },
      );
    } catch (e) {
      return {"success": false, "message": "Failed to get attendance history: $e"};
    }
  }
}