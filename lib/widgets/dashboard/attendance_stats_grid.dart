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
    // Gunakan data statistik dari API
    final Map<String, dynamic> statistics = attendanceProvider.statistics;
    print(statistics);
    
    // Hitung total hari kerja dalam bulan initotal
    final int totalDays = statistics['total'] ?? 0;
    
    // Hitung jumlah hadir (termasuk dinas)
    final int hadir = (statistics['hadir'] ?? 0) + (statistics['dinas'] ?? 0);
    
    // Hitung jumlah tidak hadir (izin + cuti + sakit)
    final int tidakHadir = (statistics['izin'] ?? 0) + 
                          (statistics['cuti'] ?? 0) + 
                          (statistics['sakit'] ?? 0);

    final List<Map<String, dynamic>> statsList = [
      {
        'title': 'Hadir',
        'value': hadir,
        'color': AppColors.success,
        'icon': Icons.check_circle_outline,
        'subtitle': 'Hari',
        'percentage': totalDays > 0 ? (hadir / totalDays * 100).round() : 0,
      },
      {
        'title': 'Tidak Hadir',
        'value': tidakHadir,
        'color': AppColors.error,
        'icon': Icons.event_busy,
        'subtitle': 'Hari',
        'percentage': totalDays > 0 ? (tidakHadir / totalDays * 100).round() : 0,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan Bulan Ini',
              style: AppTypography.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
                ),
                Text(
                  'Total: $totalDays hari',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
        border: Border.all(
          color: stat['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: stat['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                stat['icon'],
                color: stat['color'],
                  size: 16,
                ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
          Text(
            stat['value'].toString(),
            style: AppTypography.headline3.copyWith(
              fontWeight: FontWeight.bold,
              color: stat['color'],
            ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      stat['subtitle'],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${stat['percentage']}% dari total',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}