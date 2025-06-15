import '../api/api_service.dart';
import '../api/endpoints.dart';
import '../models/leave_model.dart';

abstract class LeaveRepository {
  Future<Map<String, dynamic>> getLeaves({int page = 1, int limit = 10});
  Future<Map<String, dynamic>> createLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String description,
  });
  Future<Map<String, dynamic>> getLeaveDetail(int id);
}

class LeaveRepositoryImpl implements LeaveRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Map<String, dynamic>> getLeaves({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.leaves,
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response['success']) {
        final data = response['data'];
        final List<LeaveModel> leaves = (data['data'] as List)
            .map((item) => LeaveModel.fromJson(item))
            .toList();

        return {
          'success': true,
          'data': leaves,
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> createLeave({
    required DateTime startDate,
    required DateTime endDate,
    required String category,
    required String description,
  }) async {
    try {
      final leaveData = {
        'tdkhadir_mulai': startDate.toIso8601String(),
        'tdkhadir_selesai': endDate.toIso8601String(),
        'tdkhadir_kat': category,
        'tdkhadir_ket': description,
      };

      final response = await _apiService.post(
        ApiEndpoints.leaves,
        body: leaveData,
      );

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getLeaveDetail(int id) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.leaveDetail}$id',
      );

      if (response['success']) {
        return {
          'success': true,
          'data': LeaveModel.fromJson(response['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
