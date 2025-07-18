class ApiEndpoints {
  // Base URL
  static const String baseUrl = "https://probable-grouse-firstly.ngrok-free.app";

  // Auth endpoints
  static const String login = "/auth/login";
  static const String userProfile = "/user";

  // Attendance endpoints
  static const String createAttendance = "/user/kehadiran";
  static const String todayAttendance = "/user/kehadiran/today";
  static const String attendanceHistory = "/user/kehadiran";

  // Office endpoints
  static const String offices = "/user/lokasi";

  // Leave endpoints
  static const String leaves = "/user/ketidakhadiran";
  static const String leaveDetail = "/user/ketidakhadiran/"; // Append ID

  // Late Arrival Request endpoints
  static const String lateArrivalRequests = "/permohonan-terlambat/";
  static const String myLateArrivalRequests = "/permohonan-terlambat/my-requests";
  static const String todayLateArrivalRequest = "/permohonan-terlambat/today";

  // Notification endpoints
  static const String notifications = "/user/notifikasi";
  static const String saveFcmToken = "/user/fcm-token"; // New endpoint for FCM token
  static const String markNotificationRead = "/user/notifikasi/"; // Append ID + /read
  static const String markAllNotificationsRead = "/user/notifikasi/read-all";
}