import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/attendance_model.dart';
import '../../../styles/colors.dart';
import '../../../styles/typography.dart';
import 'status_badge.dart';

class AttendanceCard extends StatelessWidget {
  final int index;
  final DateTime date;
  final Attendance? attendance;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;

  const AttendanceCard({
    super.key,
    required this.index,
    required this.date,
    required this.attendance,
    required this.isExpanded,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAttendance = attendance != null;
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    final bool isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    Color cardColor;
    Color borderColor;
    double elevation = 2;

    if (isToday) {
      cardColor = AppColors.infoLight;
      borderColor = AppColors.primaryLight;
      elevation = 3;
    } else if (hasAttendance) {
      cardColor = AppColors.white;
      borderColor = AppColors.infoLight;
      elevation = 2;
    } else if (isPast) {
      // More distinct background for past dates without attendance
      cardColor = AppColors.background;
      borderColor = AppColors.divider;
      elevation = 1;
    } else {
      // Future dates without attendance
      cardColor = AppColors.white;
      borderColor = AppColors.divider;
      elevation = 1.5;
    }

    return GestureDetector(
      onTap: onToggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: elevation,
              offset: Offset(0, elevation / 2),
            ),
          ],
          border: Border.all(color: borderColor, width: hasAttendance ? 1.2 : 1),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status indicator dot
                  if (!hasAttendance && !isToday)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPast ? AppColors.error : AppColors.textHint,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('EEEE', 'id_ID').format(date),
                              style: AppTypography.subtitle1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: hasAttendance || isToday
                                    ? AppColors.textPrimary
                                    : (isPast ? AppColors.textSecondary : AppColors.textPrimary),
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'HARI INI',
                                  style: AppTypography.overline.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy', 'id_ID').format(date),
                          style: AppTypography.bodyText2.copyWith(
                            color: hasAttendance || isToday
                                ? AppColors.textSecondary
                                : (isPast ? AppColors.textHint : AppColors.textSecondary),
                          ),
                        ),
                        if (!isExpanded && hasAttendance) ...[
                          const SizedBox(height: 8),
                          _buildCompactAttendanceInfo(attendance!),
                        ],
                        if (!hasAttendance && !isExpanded) ...[
                          const SizedBox(height: 4),
                          Text(
                            isPast ? 'Tidak ada absensi' : 'Belum ada absensi',
                            style: AppTypography.caption.copyWith(
                              fontStyle: FontStyle.italic,
                              color: isPast ? AppColors.error : AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: hasAttendance ? AppColors.infoLight : AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: hasAttendance ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded && hasAttendance)
              _buildExpandedAttendanceDetails(attendance!),
            if (!hasAttendance && isExpanded)
              Padding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                child: Row(
                  children: [
                    Icon(
                      isPast ? Icons.event_busy : Icons.event_available,
                      size: 18,
                      color: isPast ? AppColors.error : AppColors.textHint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isPast
                            ? 'Tidak ada rekaman absensi untuk tanggal ini'
                            : 'Belum ada rekaman absensi',
                        style: AppTypography.bodyText2.copyWith(
                          color: isPast ? AppColors.error : AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactAttendanceInfo(Attendance attendance) {
    final DateTime? checkInTime = attendance.checkInTime;
    final DateTime? checkOutTime = attendance.checkOutTime;
    final bool isLate = attendance.checkInStatus?.toLowerCase() == 'telat';
    final bool isEarlyOut = attendance.checkOutStatus?.toLowerCase() == 'pulang_awal';

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.login_rounded,
                size: 14,
                color: isLate ? AppColors.error : AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                checkInTime != null ? DateFormat('HH:mm').format(checkInTime) : '-',
                style: AppTypography.bodyText2.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isLate ? AppColors.error : AppColors.success,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 14,
                color: isEarlyOut ? AppColors.warning : AppColors.info,
              ),
              const SizedBox(width: 4),
              Text(
                checkOutTime != null ? DateFormat('HH:mm').format(checkOutTime) : '-',
                style: AppTypography.bodyText2.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isEarlyOut ? AppColors.warning : AppColors.info,
                ),
              ),
            ],
          ),
        ),
        StatusBadge(status: attendance.status ?? 'tidak hadir', small: true),
      ],
    );
  }

  Widget _buildExpandedAttendanceDetails(Attendance attendance) {
    final DateTime? checkInTime = attendance.checkInTime;
    final DateTime? checkOutTime = attendance.checkOutTime;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Masuk',
                  checkInTime,
                  attendance.checkInStatus == 'telat',
                  Icons.login_rounded,
                  attendance.checkInStatus,
                ),
              ),
              Container(
                height: 70,
                width: 1,
                color: AppColors.divider,
              ),
              Expanded(
                child: _buildTimeInfo(
                  'Keluar',
                  checkOutTime,
                  attendance.checkOutStatus == 'pulang_awal',
                  Icons.logout_rounded,
                  attendance.checkOutStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusBadge(status: attendance.status ?? 'tidak hadir'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
      String label,
      DateTime? time,
      bool isLate,
      IconData icon,
      String? status,
      ) {
    final color = time == null
        ? AppColors.textHint
        : (isLate ? AppColors.error : AppColors.success);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time != null ? DateFormat('HH:mm:ss').format(time) : '-',
            style: AppTypography.subtitle1.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (status != null && status.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatStatus(status),
                style: AppTypography.overline.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'telat':
        return 'Terlambat';
      case 'pulang_awal':
        return 'Pulang Awal';
      case 'normal':
        return 'Tepat Waktu';
      case 'hadir':
        return 'Hadir';
      case 'tidak hadir':
        return 'Tidak Hadir';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}