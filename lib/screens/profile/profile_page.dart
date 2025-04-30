import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_page.dart';
import 'package:intl/intl.dart';
import '../../styles/colors.dart';
import '../../widgets/dashboard/app_header.dart';
import '../../widgets/profile/personal_info_section.dart';
import '../../widgets/profile/settings_section.dart';
import '../../widgets/profile/logout_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        authProvider.getUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final isLoading = authProvider.isLoading;

        // Format join date if available
        String joinDate = 'Not available';
        if (user != null && user.createdAt != null) {
          try {
            joinDate = DateFormat('dd MMMM yyyy').format(user.createdAt!);
          } catch (e) {
            joinDate = 'Invalid date';
          }
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            onRefresh: () async {
              authProvider.clearError();
              return authProvider.getUserProfile();
            },
            color: AppColors.primary,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                AppHeader(
                  currentDate: _currentDate,
                  user: user,
                  isLoading: isLoading,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        PersonalInfoSection(user: user, joinDate: joinDate),
                        const SizedBox(height: 24),
                        const SettingsSection(),
                        const SizedBox(height: 32),
                        LogoutButton(
                          onLogout: () => _handleLogout(context),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => const LogoutConfirmDialog(),
    );

    if (shouldLogout == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}

// Helper function that could be moved to a utilities file
void showCustomSnackBar(BuildContext context, String message, {Duration? duration}) {
  // Clear any existing snackbars first
  ScaffoldMessenger.of(context).clearSnackBars();

  // Show new snackbar with proper positioning to avoid FAB
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration ?? const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: 80, // Add enough margin to avoid the FAB
        left: 16,
        right: 16,
      ),
    ),
  );
}