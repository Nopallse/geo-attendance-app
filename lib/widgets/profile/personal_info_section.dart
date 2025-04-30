import 'package:flutter/material.dart';
import '../../../styles/colors.dart';
import '../../../styles/typography.dart';
import 'info_tile.dart';

class PersonalInfoSection extends StatelessWidget {
  final dynamic user;
  final String joinDate;

  const PersonalInfoSection({
    super.key,
    required this.user,
    required this.joinDate,
  });

  @override
  Widget build(BuildContext context) {
    String employeeId = user?.deviceId ?? '-';
    String email = user?.email ?? '-';
    String phone = user?.phone ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Informasi Pribadi',
            style: AppTypography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InfoTile(
                icon: Icons.mail_outline_rounded,
                title: 'Email',
                subtitle: email,
                showDivider: true,
              ),
              InfoTile(
                icon: Icons.phone_outlined,
                title: 'Nomor Telepon',
                subtitle: phone,
                showDivider: true,
              ),
              InfoTile(
                icon: Icons.badge_outlined,
                title: 'ID Karyawan',
                subtitle: employeeId,
                showDivider: true,
              ),
              InfoTile(
                icon: Icons.calendar_today_outlined,
                title: 'Tanggal Bergabung',
                subtitle: joinDate,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}