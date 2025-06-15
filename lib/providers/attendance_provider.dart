import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/models/attendance_model.dart';
import '../data/repositories/attendance_repository.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceRepository _attendanceRepository;

  // Dependency injection through constructor
  AttendanceProvider({required AttendanceRepository attendanceRepository})
      : _attendanceRepository = attendanceRepository;

  Attendance? _todayAttendance;
  List<Attendance> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  
  // Tambahkan variabel untuk statistik
  Map<String, dynamic> _statistics = {};

  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  Map<String, dynamic> get statistics => _statistics;

  // Check in or check out
  Future<bool> createAttendance(bool isCheckIn, LatLng position, lokasiId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceRepository.createAttendance(
        isCheckIn,
        position.latitude,
        position.longitude,
        lokasiId,
      );

      if (result['success']) {
        _todayAttendance = null;
        notifyListeners();

        await getTodayAttendance();

        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get today's attendance
  Future<void> getTodayAttendance() async {
    _isLoading = true;
    _errorMessage = null;
    _todayAttendance = null;
    notifyListeners();

    try {
      final result = await _attendanceRepository.getTodayAttendance();

      if (result['success']) {
        if (result['data'] != null) {
          debugPrint('API Response: $result');
          _todayAttendance = Attendance.fromJson(result['data']);
          debugPrint('Today Attendance provider: $_todayAttendance');
        } else {
          _todayAttendance = null;
        }
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get attendance history (initial load)
  Future<void> getAttendanceHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _attendanceHistory = [];
      _hasMoreData = true;
      _statistics = {};
    }

    if (_isLoading || (!_hasMoreData && !refresh)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceRepository.getAttendanceHistory(
        page: _currentPage,
        limit: 31,
      );

      if (result['success']) {
        debugPrint('API Response history success: $result');

        final dynamic data = result['data'];
        List<dynamic> attendanceData = [];

        // Handle nested data structure
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          if (data['success'] == true) {
            // Ambil data absensi
            if (data['data'] is List) {
              attendanceData = data['data'];
            }
            
            // Ambil data statistik
            if (data.containsKey('statistics') && data['statistics'] is Map<String, dynamic>) {
              _statistics = Map<String, dynamic>.from(data['statistics']);
              debugPrint('Statistics data: $_statistics');
            }
            debugPrint('Attendance data: $attendanceData');
          }
        } else if (data is List) {
          attendanceData = data;
        }

        final List<Attendance> newAttendances =
            attendanceData.map((item) => Attendance.fromJson(item)).toList();
        debugPrint('new attendances data: $newAttendances');

        if (newAttendances.isEmpty) {
          _hasMoreData = false;
        } else {
          _attendanceHistory.addAll(newAttendances);
          _currentPage++;
        }
      } else {
        debugPrint('API Response history: $result');
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching attendance history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}