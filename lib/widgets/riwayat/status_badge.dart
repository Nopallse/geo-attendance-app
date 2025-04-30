import 'package:flutter/material.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status.toLowerCase() == 'hadir';
    final backgroundColor = (isPresent ? AppColors.successLight : AppColors.errorLight);
    final textColor = isPresent ? AppColors.success : AppColors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 12,
        vertical: small ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPresent ? Icons.check_circle : Icons.warning_rounded,
            color: textColor,
            size: small ? 10 : 16,
          ),
          SizedBox(width: small ? 2 : 4),
          Text(
            _formatStatus(status),
            style: (small ? AppTypography.overline : AppTypography.caption).copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
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