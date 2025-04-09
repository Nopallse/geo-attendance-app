import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_page.dart';
import 'package:intl/intl.dart';
import 'package:absensi_app/styles/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Use colors from AppColors class
  final Color primaryColor = AppColors.primary;
  final Color primaryLightColor = AppColors.primaryLight;
  final Color primaryDarkColor = AppColors.primaryDark;
  final Color accentColor = AppColors.accent;
  final Color backgroundColor = AppColors.background;
  final Color surfaceColor = AppColors.cardBackground;
  final Color mutedTextColor = AppColors.textSecondary;
  final Color redColor = AppColors.error;

  @override
  void initState() {
    super.initState();
    // Load user profile when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        authProvider.getUserProfile();
      }
    });
  }

  void _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: redColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Access user data from the provider
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
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: const Text(
              'Profil',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            backgroundColor: primaryColor,
            foregroundColor: AppColors.white,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              authProvider.clearError();
              return authProvider.getUserProfile();
            },
            color: primaryColor,
            child: isLoading
                ? _buildLoadingState()
                : _buildProfileContent(user, joinDate),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildProfileContent(user, String joinDate) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Profile Card
          _buildProfileCard(user),

          const SizedBox(height: 24),

          // Personal Information Card
          _buildPersonalInfoCard(user, joinDate),

          const SizedBox(height: 24),

          // Settings Card
          _buildSettingsCard(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard(user) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.5),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Picture with Edit Button
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, primaryLightColor],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        // TODO: Implement change profile picture
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feature coming soon!'),
                            behavior: SnackBarBehavior.floating, // This is key
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // User name and position
            Text(
              user?.name ?? 'User Name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.position ?? 'Software Developer',
              style: TextStyle(
                fontSize: 16,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              user?.department ?? 'IT Department',
              style: TextStyle(
                fontSize: 14,
                color: mutedTextColor,
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                    label: const Text('Edit Profil'),
                    onPressed: () {
                      // TODO: Implement edit profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Keluar'),
                    onPressed: () => _handleLogout(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: redColor,
                      side: BorderSide(color: redColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(user, String joinDate) {
    String employeeId = user?.deviceId ?? '-';
    String email = user?.email ?? '-';
    String phone = user?.phone ?? '-';

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.5),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Pribadi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                'Detail informasi pribadi Anda',
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Information Fields
            _buildInfoRow('Nama Lengkap', user?.name ?? 'User Name'),
            _buildDivider(),

            _buildInfoRow(
              'Email',
              email,
              icon: Icons.mail_outline,
            ),
            _buildDivider(),

            _buildInfoRow(
              'Nomor Telepon',
              phone,
              icon: Icons.phone_outlined,
            ),
            _buildDivider(),

            _buildInfoRow(
              'ID Karyawan',
              employeeId,
              icon: Icons.badge_outlined,
            ),
            _buildDivider(),

            _buildInfoRow(
              'Tanggal Bergabung',
              joinDate,
              icon: Icons.calendar_today_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.5),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                'Kelola pengaturan aplikasi',
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Settings Options
            _buildSettingItem(
              'Pengaturan Notifikasi',
              icon: Icons.notifications_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildDivider(),

            _buildSettingItem(
              'Bahasa',
              icon: Icons.language_outlined,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _buildDivider(),

            _buildSettingItem(
              'Keamanan',
              icon: Icons.security_outlined,
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
    );
  }


  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Divider(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: mutedTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildSettingItem(String title, {required VoidCallback onTap, required IconData icon}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: mutedTextColor,
            ),
          ],
        ),
      ),
    );
  }
}