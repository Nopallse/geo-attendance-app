import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/attendance_model.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';
import 'shimmer_widgets.dart';

class AttendanceSummary extends StatelessWidget {
  final Attendance? todayAttendance;
  final bool isLoading;

  const AttendanceSummary({
    super.key,
    required this.todayAttendance,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Statuses for the cards
    bool hasCheckedIn = todayAttendance?.checkInTime != null;
    bool hasCheckedOut = todayAttendance?.checkOutTime != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Kehadiran Hari Ini',
            style: AppTypography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          isLoading
              ? const ShimmerAttendanceCards()
              : Row(
            children: [
              // Check-in card
              Expanded(
                child: _buildStatusCard(
                  'Masuk',
                  hasCheckedIn,
                  todayAttendance?.checkInTime != null
                      ? DateFormat('HH:mm').format(todayAttendance!.checkInTime!)
                      : '--:--',
                  todayAttendance?.checkInStatus,
                  hasCheckedIn ? AppColors.success : AppColors.textHint,
                  Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 12),
              // Check-out card
              Expanded(
                child: _buildStatusCard(
                  'Keluar',
                  hasCheckedOut,
                  todayAttendance?.checkOutTime != null
                      ? DateFormat('HH:mm').format(todayAttendance!.checkOutTime!)
                      : '--:--',
                  todayAttendance?.statusKeluar,
                  hasCheckedOut ? AppColors.success : AppColors.textHint,
                  Icons.logout_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String title,
      bool isCompleted,
      String time,
      String? status,
      Color color,
      IconData icon,
      ) {
    return Container(
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitle1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted ? 'Selesai' : 'Belum',
                    style: AppTypography.caption.copyWith(
                      color: isCompleted ? AppColors.success : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            time,
            style: AppTypography.headline3.copyWith(
              fontWeight: FontWeight.bold,
              color: isCompleted ? AppColors.textPrimary : AppColors.textHint,
            ),
          ),
          if (status != null && status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}