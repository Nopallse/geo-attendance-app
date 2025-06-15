import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';
import '../../widgets/notification/notification_group_header.dart';
import '../../widgets/notification/notification_card.dart';
import '../../widgets/notification/notification_empty_state.dart';
import '../../widgets/notification/notification_detail_sheet.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
      _setupNotificationListener();
    });
  }

  void _setupNotificationListener() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Refresh notifications when a new message arrives
      context.read<NotificationProvider>().refreshNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationProvider>().loadNotifications();
    }
  }

  Map<String, List<NotificationModel>> _groupNotifications(List<NotificationModel> notifications) {
    final grouped = <String, List<NotificationModel>>{};
    
    for (var notification in notifications) {
      if (_showUnreadOnly && notification.isRead) continue;
      
      final date = _getGroupDate(notification.createdAt);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(notification);
    }
    
    return grouped;
  }

  String _getGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Hari Ini';
    } else if (notificationDate == yesterday) {
      return 'Kemarin';
    } else {
      return 'Minggu Ini';
    }
  }

  void _showNotificationDetails(NotificationModel notification) async {
    // Mark notification as read when opened
    if (!notification.isRead) {
      await context.read<NotificationProvider>().markNotificationAsRead(notification.notifId);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailSheet(notification: notification),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tampilkan Semua'),
              leading: Icon(
                Icons.all_inbox,
                color: _showUnreadOnly ? Colors.grey : AppColors.primary,
              ),
              onTap: () {
                setState(() => _showUnreadOnly = false);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Belum Dibaca'),
              leading: Icon(
                Icons.mark_email_unread,
                color: _showUnreadOnly ? AppColors.primary : Colors.grey,
              ),
              onTap: () {
                setState(() => _showUnreadOnly = true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: AppTypography.headline6.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.mark_email_unread : Icons.filter_list,
              color: _showUnreadOnly ? Colors.white : Colors.white70,
            ),
            onPressed: _showFilterOptions,
            tooltip: 'Filter Notifikasi',
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              final provider = context.read<NotificationProvider>();
              await provider.markAllNotificationsAsRead();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua notifikasi ditandai sebagai dibaca'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            tooltip: 'Tandai semua sebagai dibaca',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.notifications.isEmpty) {
              return const NotificationEmptyState();
            }

            final groupedNotifications = _groupNotifications(provider.notifications);

            if (groupedNotifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mark_email_read,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showUnreadOnly
                          ? 'Tidak ada notifikasi yang belum dibaca'
                          : 'Tidak ada notifikasi',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: provider.refreshNotifications,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _calculateItemCount(groupedNotifications),
                itemBuilder: (context, index) => _buildListItem(
                  context,
                  index,
                  groupedNotifications,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _calculateItemCount(Map<String, List<NotificationModel>> groupedNotifications) {
    int count = 0;
    groupedNotifications.forEach((date, notifs) {
      count += 1; // Header
      count += notifs.length; // Notifications
    });
    return count;
  }

  Widget? _buildListItem(
    BuildContext context,
    int index,
    Map<String, List<NotificationModel>> groupedNotifications,
  ) {
    int currentIndex = 0;
    for (var entry in groupedNotifications.entries) {
      if (currentIndex == index) {
        return NotificationGroupHeader(title: entry.key);
      }
      currentIndex++;

      for (var notification in entry.value) {
        if (currentIndex == index) {
          return NotificationCard(
              notification: notification,
              onTap: () => _showNotificationDetails(notification),
            );

        }
        currentIndex++;
      }
    }
    return null;
  }
}