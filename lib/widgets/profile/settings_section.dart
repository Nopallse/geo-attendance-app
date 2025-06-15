import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/delight_toast.dart';
import '../../../styles/colors.dart';
import '../../../styles/typography.dart';
import 'setting_tile.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  void _showDelightToast(BuildContext context, String message) {
    DelightToastBar(
      autoDismiss: true,
      snackbarDuration: const Duration(seconds: 2),
      position: DelightSnackbarPosition.top,
      builder: (context) => ToastCard(
        leading: const Icon(
          Icons.info_outline,
          size: 28,
          color: Colors.blue,
        ),
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Pengaturan',
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
              SettingTile(
                icon: Icons.notifications_outlined,
                title: 'Pengaturan Notifikasi',
                showDivider: true,
                onTap: () {
                  _showDelightToast(context, 'Feature coming soon!');
                },
              ),
              SettingTile(
                icon: Icons.language_outlined,
                title: 'Bahasa',
                showDivider: true,
                onTap: () {
                  _showDelightToast(context, 'Feature coming soon!');
                },
              ),
              SettingTile(
                icon: Icons.security_outlined,
                title: 'Keamanan',
                showDivider: true,
                onTap: () {
                  _showDelightToast(context, 'Feature coming soon!');
                },
              ),
              SettingTile(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan & Dukungan',
                showDivider: false,
                onTap: () {
                  _showDelightToast(context, 'Feature coming soon!');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}