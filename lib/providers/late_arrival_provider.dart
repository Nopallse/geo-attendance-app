import 'package:flutter/foundation.dart';
import '../data/models/late_arrival_request_model.dart';
import '../data/repositories/late_arrival_repository.dart';

class LateArrivalProvider with ChangeNotifier {
  final LateArrivalRepository _repository;

  LateArrivalProvider({required LateArrivalRepository repository})
      : _repository = repository;

  // State variables
  List<LateArrivalRequest> _requests = [];
  LateArrivalRequest? _todayRequest;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  PaginationInfo? _pagination;

  // Getters
  List<LateArrivalRequest> get requests => _requests;
  LateArrivalRequest? get todayRequest => _todayRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasMoreData => _hasMoreData;
  PaginationInfo? get pagination => _pagination;

  // Create new late arrival request
  Future<bool> createLateArrivalRequest(CreateLateArrivalRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.createLateArrivalRequest(request);

      if (result['success']) {
        _successMessage = result['message'] ?? 'Permohonan berhasil diajukan';
        
        // Refresh the requests list
        await getMyRequests(refresh: true);
        
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengajukan permohonan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user's late arrival requests
  Future<void> getMyRequests({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _requests = [];
      _hasMoreData = true;
      _pagination = null;
    }

    if (_isLoading || (!_hasMoreData && !refresh)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMyLateArrivalRequests(
        page: _currentPage,
        limit: 10,
      );

      if (result['success']) {
        debugPrint('Late arrival requests result: $result');

        // Handle nested data structure from API service
        // The API service wraps the actual response in a 'data' field
        final dynamic outerData = result['data'];
        
        if (outerData is Map<String, dynamic>) {
          // This is the actual API response
          final actualResponse = outerData;
          
          if (actualResponse['success'] == true) {
            final dynamic requestsData = actualResponse['data'];
            final List<LateArrivalRequest> newRequests = [];
            
            if (requestsData is List) {
              for (final item in requestsData) {
                try {
                  if (item is Map<String, dynamic>) {
                    newRequests.add(LateArrivalRequest.fromJson(item));
                  }
                } catch (e) {
                  debugPrint('Error parsing late arrival request item: $e, item: $item');
                }
              }
            }

            if (newRequests.isEmpty) {
              _hasMoreData = false;
            } else {
              _requests.addAll(newRequests);
              _currentPage++;
            }

            // Handle pagination info
            if (actualResponse['pagination'] != null) {
              try {
                _pagination = PaginationInfo.fromJson(actualResponse['pagination']);
              } catch (e) {
                debugPrint('Error parsing pagination: $e');
              }
            }
          } else {
            _errorMessage = actualResponse['message'] ?? 'Gagal memuat data';
          }
        } else {
          _errorMessage = 'Format respons tidak valid';
        }
      } else {
        _errorMessage = result['message'] ?? 'Gagal memuat data';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      debugPrint('Error getting late arrival requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get today's late arrival request
  Future<void> getTodayRequest() async {
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getTodayLateArrivalRequest();

      if (result['success']) {
        debugPrint('Today late arrival request result: $result');
        
        // Handle nested data structure from API service
        final dynamic outerData = result['data'];
        
        if (outerData is Map<String, dynamic>) {
          // This is the actual API response
          final actualResponse = outerData;
          
          if (actualResponse['success'] == true) {
            final dynamic requestData = actualResponse['data'];
            
            if (requestData != null && requestData is Map<String, dynamic>) {
              try {
                _todayRequest = LateArrivalRequest.fromJson(requestData);
              } catch (e) {
                debugPrint('Error parsing today request: $e, data: $requestData');
                _todayRequest = null;
              }
            } else {
              // No request for today - this is normal
              _todayRequest = null;
            }
          } else {
            // API returned success but with a message (like "Tidak ada permohonan")
            _todayRequest = null;
            debugPrint('No late arrival request for today: ${actualResponse['message']}');
          }
        } else {
          _todayRequest = null;
          debugPrint('Invalid response format for today request');
        }
      } else {
        _errorMessage = result['message'];
        _todayRequest = null;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _todayRequest = null;
      debugPrint('Error getting today late arrival request: $e');
    }

    notifyListeners();
  }

  // Delete late arrival request
  Future<bool> deleteLateArrivalRequest(int id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.deleteLateArrivalRequest(id);

      if (result['success']) {
        _successMessage = result['message'] ?? 'Permohonan berhasil dihapus';
        
        // Remove from local list
        _requests.removeWhere((request) => request.id == id);
        
        // Update today request if it was deleted
        if (_todayRequest?.id == id) {
          _todayRequest = null;
        }
        
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Gagal menghapus permohonan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Check if user can create request for specific date
  bool canCreateRequestForDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    // Can only create request for future dates (minimum tomorrow)
    if (date.isBefore(tomorrow)) {
      return false;
    }

    // Check if there's already a request for this date
    final existingRequest = _requests.where((request) {
      final requestDate = DateTime(
        request.tanggalTerlambat.year,
        request.tanggalTerlambat.month,
        request.tanggalTerlambat.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return requestDate.isAtSameMomentAs(targetDate);
    }).toList();

    return existingRequest.isEmpty;
  }

  // Get request for specific date
  LateArrivalRequest? getRequestForDate(DateTime date) {
    try {
      return _requests.firstWhere((request) {
        final requestDate = DateTime(
          request.tanggalTerlambat.year,
          request.tanggalTerlambat.month,
          request.tanggalTerlambat.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return requestDate.isAtSameMomentAs(targetDate);
      });
    } catch (e) {
      return null;
    }
  }

  // Get statistics
  Map<String, int> getStatistics() {
    final stats = <String, int>{
      'total': _requests.length,
      'pending': 0,
      'approved': 0,
      'rejected': 0,
    };

    for (final request in _requests) {
      switch (request.status) {
        case 'pending':
          stats['pending'] = (stats['pending'] ?? 0) + 1;
          break;
        case 'approved':
          stats['approved'] = (stats['approved'] ?? 0) + 1;
          break;
        case 'rejected':
          stats['rejected'] = (stats['rejected'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }
}
