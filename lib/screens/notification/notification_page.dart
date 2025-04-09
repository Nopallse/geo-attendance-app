import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color accent = Color(0xFF03A9F4);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Greyscale
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabledButton = Color(0xFFBDBDBD);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample notification data
  // Initialized in initState to ensure proper state management
  late List<Map<String, dynamic>> notifications;

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);

    // Add listener to sync tab changes
    _tabController.addListener(() {
      // Only call setState when the tab actually changes
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Initialize notifications with dummy data
    notifications = [
      {
        'id': 1,
        'type': 'info',
        'title': 'Pengumuman Libur',
        'message': 'Kantor akan libur pada tanggal 25 Maret 2025 untuk perayaan hari raya.',
        'time': '2 jam lalu',
        'read': false,
      },
      {
        'id': 2,
        'type': 'success',
        'title': 'Absensi Berhasil',
        'message': 'Anda telah berhasil melakukan check in pada pukul 08:02.',
        'time': '5 jam lalu',
        'read': true,
      },
      {
        'id': 3,
        'type': 'info',
        'title': 'Perubahan Jadwal',
        'message': 'Mulai minggu depan, jam kerja akan berubah menjadi 08:30 - 17:30.',
        'time': '1 hari lalu',
        'read': false,
      },
      {
        'id': 4,
        'type': 'success',
        'title': 'Absensi Berhasil',
        'message': 'Anda telah berhasil melakukan check out pada pukul 17:05.',
        'time': '1 hari lalu',
        'read': true,
      },
      {
        'id': 5,
        'type': 'info',
        'title': 'Pembaruan Sistem',
        'message': 'Sistem absensi akan diperbarui pada tanggal 20 Maret 2025. Mohon maaf atas ketidaknyamanannya.',
        'time': '2 hari lalu',
        'read': true,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get unreadCount => notifications.where((n) => n['read'] == false).length;

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['read'] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Semua notifikasi telah ditandai dibaca'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 80.0,
          left: 20.0,
          right: 20.0,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: markAllAsRead,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Tandai Dibaca'),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.white,
              indicatorWeight: 3,
              labelColor: AppColors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: [
                const Tab(text: 'Semua'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum Dibaca'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const Tab(text: 'Dibaca'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // All notifications
            _buildNotificationList(notifications),

            // Unread notifications
            _buildNotificationList(
                notifications.where((n) => n['read'] == false).toList()
            ),

            // Read notifications
            _buildNotificationList(
                notifications.where((n) => n['read'] == true).toList()
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notificationList) {
    return notificationList.isEmpty
        ? _buildEmptyState()
        : ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notificationList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildNotificationCard(notificationList[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isInfo = notification['type'] == 'info';
    final bool isRead = notification['read'] as bool;

    return GestureDetector(
      onTap: () {
        // Mark as read when tapped
        if (!isRead) {
          setState(() {
            notification['read'] = true;
          });
        }

        // Show full notification details
        _showNotificationDetails(notification);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent border for unread
            if (!isRead)
              Container(
                width: 5,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isInfo ? AppColors.infoLight : AppColors.successLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInfo ? Icons.info_outline : Icons.check_circle,
                        size: 18,
                        color: isInfo ? AppColors.primary : AppColors.success,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header row with title and time
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: TextStyle(
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  notification['time'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Message with max 2 lines
                          Text(
                            notification['message'],
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isInfo = notification['type'] == 'info';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isInfo ? AppColors.infoLight : AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isInfo ? Icons.info_outline : Icons.check_circle,
                      size: 22,
                      color: isInfo ? AppColors.primary : AppColors.success,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          notification['time'],
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Full message
              Text(
                notification['message'],
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}