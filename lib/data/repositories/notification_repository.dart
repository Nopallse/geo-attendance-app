import 'dart:convert';
import '../models/notification_model.dart';
import '../api/api_service.dart';
import '../api/endpoints.dart';

abstract class NotificationRepository {
  Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? limit,
    bool? isRead,
  });
  
  Future<bool> markNotificationAsRead(int notificationId);
  Future<bool> markAllNotificationsAsRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService _apiService;

  NotificationRepositoryImpl(this._apiService);

  @override
  Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? limit,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (isRead != null) queryParams['is_read'] = isRead.toString();

      final response = await _apiService.get(
        ApiEndpoints.notifications,
        queryParams: queryParams,
      );

      if (response['success']) {
        final data = response['data'];
        final notifications = (data['data'] as List)
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        return {
          'notifications': notifications,
          'pagination': data['pagination'],
        };
      }

      throw Exception(response['message'] ?? 'Failed to load notifications');
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  @override
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _apiService.patch(
        '${ApiEndpoints.markNotificationRead}$notificationId/read',
      );

      if (response['success']) {
        return true;
      }

      throw Exception(response['message'] ?? 'Failed to mark notification as read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final response = await _apiService.patch(
        ApiEndpoints.markAllNotificationsRead,
      );

      if (response['success']) {
        return true;
      }

      throw Exception(response['message'] ?? 'Failed to mark all notifications as read');
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
} 