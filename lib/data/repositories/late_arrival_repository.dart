import 'package:flutter/foundation.dart';
import '../models/late_arrival_request_model.dart';
import '../api/api_service.dart';

class LateArrivalRepository {
  final ApiService _apiService = ApiService();

  // Create late arrival request
  Future<Map<String, dynamic>> createLateArrivalRequest(
      CreateLateArrivalRequest request) async {
    try {
      return await _apiService.post(
        '/permohonan-terlambat/',
        body: request.toJson(),
      );
    } catch (e) {
      debugPrint('Error creating late arrival request: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: ${e.toString()}',
      };
    }
  }

  // Get user's late arrival requests
  Future<Map<String, dynamic>> getMyLateArrivalRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _apiService.get(
        '/permohonan-terlambat/my-requests',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );
    } catch (e) {
      debugPrint('Error getting late arrival requests: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: ${e.toString()}',
      };
    }
  }

  // Get today's late arrival request
  Future<Map<String, dynamic>> getTodayLateArrivalRequest() async {
    try {
      return await _apiService.get('/permohonan-terlambat/today');
    } catch (e) {
      debugPrint('Error getting today late arrival request: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: ${e.toString()}',
      };
    }
  }

  // Delete late arrival request (if needed) - using post method
  Future<Map<String, dynamic>> deleteLateArrivalRequest(int id) async {
    try {
      // Since ApiService doesn't have delete method, use post with delete action
      return await _apiService.post(
        '/permohonan-terlambat/$id/delete',
        body: {},
      );
    } catch (e) {
      debugPrint('Error deleting late arrival request: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: ${e.toString()}',
      };
    }
  }
}
