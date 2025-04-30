import 'package:flutter/material.dart';
import '../../../providers/attendance_provider.dart';
import '../../../data/models/attendance_model.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';

class AttendanceStatsGrid extends StatelessWidget {
  final AttendanceProvider attendanceProvider;

  const AttendanceStatsGrid({
    super.key,
    required this.attendanceProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Process history to get summary counts
    final List<Attendance> history = attendanceProvider.attendanceHistory;
    int hadir = 0;
    int izin = 0;
    int cuti = 0;
    int dinas = 0;

    for (var attendance in history) {
      // Assuming attendance has a 'status' field to distinguish types
      String type = attendance.status?.toLowerCase() ?? 'hadir';
      switch (type) {
        case 'hadir':
          hadir++;
          break;
        case 'izin':
          izin++;
          break;
        case 'cuti':
          cuti++;
          break;
        case 'dinas':
          dinas++;
          break;
      }
    }

    final List<Map<String, dynamic>> statsList = [
      {
        'title': 'Hadir',
        'value': hadir,
        'color': AppColors.success,
        'icon': Icons.check_circle_outline
      },
      {
        'title': 'Izin',
        'value': izin,
        'color': AppColors.warning,
        'icon': Icons.event_note
      },
      {
        'title': 'Cuti',
        'value': cuti,
        'color': const Color(0xFF9575CD),
        'icon': Icons.event_busy
      },
      {
        'title': 'Dinas',
        'value': dinas,
        'color': AppColors.info,
        'icon': Icons.business_center
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Bulan Ini',
              style: AppTypography.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: statsList.length,
              itemBuilder: (context, index) {
                final stat = statsList[index];
                return _buildStatItem(stat);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stat['color'].withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                stat['icon'],
                color: stat['color'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                stat['title'],
                style: AppTypography.bodyText2.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            stat['value'].toString(),
            style: AppTypography.headline3.copyWith(
              fontWeight: FontWeight.bold,
              color: stat['color'],
            ),
          ),
        ],
      ),
    );
  }
}