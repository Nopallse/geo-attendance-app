import 'package:flutter/foundation.dart';
import '../data/repositories/late_arrival_repository.dart';
import '../data/models/late_arrival_request_model.dart';

class LateArrivalService {
  final LateArrivalRepository _repository;

  LateArrivalService({required LateArrivalRepository repository})
      : _repository = repository;

  /// Check if user has an approved late arrival request for today
  /// Returns the approved request if found, null otherwise
  Future<LateArrivalRequest?> getTodayApprovedRequest() async {
    try {
      final result = await _repository.getTodayLateArrivalRequest();
      
      if (result['success'] && result['data'] != null) {
        final request = LateArrivalRequest.fromJson(result['data']);
        
        // Only return if the request is approved
        if (request.isApproved) {
          return request;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting today approved late arrival request: $e');
      return null;
    }
  }

  /// Calculate attendance status based on check-in time and late arrival request
  /// Returns 'hadir' if on time, 'telat' if late
  String calculateAttendanceStatus({
    required DateTime checkInTime,
    LateArrivalRequest? approvedRequest,
  }) {
    // Default check-in limit is 07:45
    final defaultLimit = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      7,
      45,
    );

    DateTime effectiveLimit = defaultLimit;

    // If there's an approved late arrival request, use its planned time as limit
    if (approvedRequest != null) {
      try {
        final timeParts = approvedRequest.jamDatangRencana.split(':');
        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          
          effectiveLimit = DateTime(
            checkInTime.year,
            checkInTime.month,
            checkInTime.day,
            hour,
            minute,
          );
        }
      } catch (e) {
        debugPrint('Error parsing late arrival time: $e');
        // Fallback to default limit if parsing fails
      }
    }

    // Check if check-in time is before the effective limit
    if (checkInTime.isBefore(effectiveLimit) || 
        checkInTime.isAtSameMomentAs(effectiveLimit)) {
      return 'hadir';
    } else {
      return 'telat';
    }
  }

  /// Get user-friendly message about attendance status
  String getAttendanceStatusMessage({
    required String status,
    LateArrivalRequest? approvedRequest,
  }) {
    if (status == 'hadir') {
      if (approvedRequest != null) {
        return 'Hadir sesuai dengan permohonan keterlambatan yang disetujui';
      } else {
        return 'Hadir tepat waktu';
      }
    } else {
      if (approvedRequest != null) {
        return 'Terlambat melebihi jam yang direncanakan (${approvedRequest.formattedTime})';
      } else {
        return 'Terlambat dari jam masuk standar (07:45)';
      }
    }
  }

  /// Validate if a new late arrival request can be created for the given date
  Future<Map<String, dynamic>> validateNewRequest({
    required DateTime targetDate,
    required String plannedTime,
    required String reason,
  }) async {
    final request = CreateLateArrivalRequest(
      tanggalTerlambat: targetDate.toIso8601String().split('T')[0],
      jamDatangRencana: plannedTime,
      alasan: reason,
    );

    final errors = request.validateAll();
    
    if (errors.isNotEmpty) {
      return {
        'valid': false,
        'errors': errors,
      };
    }

    // Additional validation: check if there's already a request for this date
    // This would require getting user's requests and checking
    // For now, we'll just return valid
    
    return {
      'valid': true,
      'errors': [],
    };
  }
}
