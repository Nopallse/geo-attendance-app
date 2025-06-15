import 'package:flutter/foundation.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  NotificationProvider(this._repository);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getNotifications(
        page: _currentPage,
        limit: 10,
      );

      final newNotifications = result['notifications'] as List<NotificationModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      _totalPages = pagination['totalPages'];
      _currentPage++;
      _hasMore = _currentPage <= _totalPages;

      if (refresh) {
        _notifications = newNotifications;
      } else {
        _notifications.addAll(newNotifications);
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final success = await _repository.markNotificationAsRead(notificationId);
      if (success) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.notifId == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            notifId: _notifications[index].notifId,
            title: _notifications[index].title,
            body: _notifications[index].body,
            type: _notifications[index].type,
            referenceId: _notifications[index].referenceId,
            isRead: true,
            createdAt: _notifications[index].createdAt,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final success = await _repository.markAllNotificationsAsRead();
      if (success) {
        // Update local state
        _notifications = _notifications.map((notification) => NotificationModel(
          notifId: notification.notifId,
          title: notification.title,
          body: notification.body,
          type: notification.type,
          referenceId: notification.referenceId,
          isRead: true,
          createdAt: notification.createdAt,
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
} 