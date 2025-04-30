import 'package:flutter/material.dart';
import '../../widgets/notification/notification_group_header.dart';
import '../../widgets/notification/notification_card.dart';
import '../../widgets/notification/notification_empty_state.dart';
import '../../widgets/notification/notification_detail_sheet.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationData();
  }

  void _loadNotificationData() {
    // Simulate async data loading
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        notifications = [
          {
            'id': 1,
            'type': 'info',
            'title': 'Pengumuman Libur',
            'message': 'Kantor akan libur pada tanggal 25 Maret 2025 untuk perayaan hari raya.',
            'time': '2 jam lalu',
            'date': 'Hari Ini',
          },
          {
            'id': 2,
            'type': 'success',
            'title': 'Absensi Berhasil',
            'message': 'Anda telah berhasil melakukan check in pada pukul 08:02.',
            'time': '5 jam lalu',
            'date': 'Hari Ini',
          },
          {
            'id': 3,
            'type': 'info',
            'title': 'Perubahan Jadwal',
            'message': 'Mulai minggu depan, jam kerja akan berubah menjadi 08:30 - 17:30.',
            'time': '1 hari lalu',
            'date': 'Kemarin',
          },
          {
            'id': 4,
            'type': 'success',
            'title': 'Absensi Berhasil',
            'message': 'Anda telah berhasil melakukan check out pada pukul 17:05.',
            'time': '1 hari lalu',
            'date': 'Kemarin',
          },
          {
            'id': 5,
            'type': 'info',
            'title': 'Pembaruan Sistem',
            'message': 'Sistem absensi akan diperbarui pada tanggal 20 Maret 2025. Mohon maaf atas ketidaknyamanannya.',
            'time': '2 hari lalu',
            'date': 'Minggu Ini',
          },
        ];
        _groupNotifications();
        isLoading = false;
      });
    });
  }

  void _groupNotifications() {
    groupedNotifications.clear();
    for (var notification in notifications) {
      final date = notification['date'] as String;
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailSheet(notification: notification),
    );
  }

  void _clearAllNotifications() {
    setState(() {
      notifications.clear();
      groupedNotifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: AppTypography.headline4.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,

      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (notifications.isEmpty) {
      return const NotificationEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => isLoading = true);
        await Future.delayed(const Duration(seconds: 1));
        _loadNotificationData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _calculateItemCount(),
        itemBuilder: _buildListItem,
      ),
    );
  }

  int _calculateItemCount() {
    int count = 0;
    groupedNotifications.forEach((date, notifs) {
      count += 1; // Header
      count += notifs.length; // Notifications
    });
    return count;
  }

  Widget? _buildListItem(BuildContext context, int index) {
    int currentIndex = 0;
    for (var entry in groupedNotifications.entries) {
      if (currentIndex == index) {
        return NotificationGroupHeader(title: entry.key);
      }
      currentIndex++;

      for (var notification in entry.value) {
        if (currentIndex == index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NotificationCard(
              notification: notification,
              onTap: () => _showNotificationDetails(notification),
            ),
          );
        }
        currentIndex++;
      }
    }
    return null;
  }

}