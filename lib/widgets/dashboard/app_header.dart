import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';
import 'shimmer_widgets.dart';

class AppHeader extends StatelessWidget {
  final DateTime currentDate;
  final User? user;
  final bool isLoading;

  const AppHeader({
    super.key,
    required this.currentDate,
    required this.user,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(currentDate);
    final String greeting = _getGreeting();

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                right: -80,
                top: -30,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -40,
                bottom: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: 20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      isLoading
                          ? _buildShimmerText(16, 100)
                          : Text(
                        greeting,
                        style: AppTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      isLoading
                          ? _buildShimmerText(28, 200)
                          : Text(
                        user?.email ?? 'User',
                        style: AppTypography.headline2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      isLoading
                          ? _buildShimmerText(14, 150)
                          : Text(
                        formattedDate,
                        style: AppTypography.bodyText2.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      isLoading
                          ? _buildShimmerText(14, 180)
                          : Row(
                        children: [
                          // NIK Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'NIP: ${user?.username ?? 'N/A'}',
                                  style: AppTypography.overline.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Jabatan Badge (jika diperlukan)
                          if (user?.username != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.work_outline,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'STAFF',
                                      style: AppTypography.overline.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  Widget _buildShimmerText(double height, double width) {
    return ShimmerTextLoader(height: height, width: width);
  }
}