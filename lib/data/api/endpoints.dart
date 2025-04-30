class ApiEndpoints {
  // Base URL
  static const String baseUrl = "https://probable-grouse-firstly.ngrok-free.app";

  // Auth endpoints
  static const String login = "/auth/login";
  static const String userProfile = "/me";

  // Attendance endpoints
  static const String createAttendance = "/absen";
  static const String todayAttendance = "/absen/today";
  static const String attendanceHistory = "/absen/history";

  // Office endpoints
  static const String offices = "/absen/kantor";
}