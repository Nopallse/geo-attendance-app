import 'package:flutter/material.dart';
import '../../../styles/colors.dart';
import '../../../styles/typography.dart';
import 'setting_tile.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SettingTile(
                icon: Icons.language_outlined,
                title: 'Bahasa',
                showDivider: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SettingTile(
                icon: Icons.security_outlined,
                title: 'Keamanan',
                showDivider: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SettingTile(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan & Dukungan',
                showDivider: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}