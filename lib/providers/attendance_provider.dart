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

  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  // Check in or check out
  Future<bool> createAttendance(bool isCheckIn, LatLng position) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceRepository.createAttendance(
        isCheckIn,
        position.latitude,
        position.longitude,
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
          _todayAttendance = Attendance.fromJson(result['data']['data']);
          debugPrint('Today Attendance: $_todayAttendance');
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
    }

    if (_isLoading || (!_hasMoreData && !refresh)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _attendanceRepository.getAttendanceHistory(
        page: _currentPage,
        limit: 10,
      );

      if (result['success']) {
        debugPrint('API Response: $result');

        final dynamic data = result['data'];
        List<dynamic> attendanceData = [];

        // Handle nested data structure
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          if (data['success'] == true && data['data'] is List) {
            attendanceData = data['data'];
          }
        } else if (data is List) {
          attendanceData = data;
        }

        final List<Attendance> newAttendances =
        attendanceData.map((item) => Attendance.fromJson(item)).toList();

        if (newAttendances.isEmpty) {
          _hasMoreData = false;
        } else {
          _attendanceHistory.addAll(newAttendances);
          _currentPage++;
        }
      } else {
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