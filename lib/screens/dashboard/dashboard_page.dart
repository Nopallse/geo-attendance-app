import 'package:absensi_app/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/office_provider.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/user_model.dart';
import '../absensi/absensi_page.dart';
import '../riwayat/riwayat_page.dart';
import '../leave/leave_form_page.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentDate;
  final ValueNotifier<int> _selectedTabIndex = ValueNotifier(0);
  bool _isRefreshing = false;

// Design constants
  final Color primaryColor = AppColors.primary;
  final Color secondaryColor = AppColors.primaryLight;
  final Color accentColor = AppColors.accent;
  final Color backgroundColor = AppColors.background;
  final Color surfaceColor = AppColors.cardBackground;
  final Color successColor = AppColors.success;
  final Color warningColor = AppColors.warning;
  final Color errorColor = AppColors.error;
  final Color infoColor = AppColors.info;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _selectedTabIndex.value = _tabController.index;
    });
    _currentDate = DateTime.now();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _selectedTabIndex.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final officeProvider = Provider.of<OfficeProvider>(context, listen: false);

    // Get user profile if not loaded
    if (authProvider.user == null) {
      await authProvider.getUserProfile();
    }

    // Get today's attendance
    await attendanceProvider.getTodayAttendance();

    // Get attendance history
    await attendanceProvider.getAttendanceHistory(refresh: true);

    // Get office locations if not loaded
    if (officeProvider.offices.isEmpty) {
      await officeProvider.getOffices();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    await _loadData();

    setState(() {
      _isRefreshing = false;
    });
  }

  void _navigateToAttendancePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AbsensiPage()),
    );
  }

  void _navigateToLeaveForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaveFormPage()),
    );
  }

  void _navigateToAttendanceHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RiwayatPage()),
    );
  }

  void _navigateToApprovalList() {
    // TODO: Implement approval list navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur persetujuan akan datang segera')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer2<AuthProvider, AttendanceProvider>(
      builder: (context, authProvider, attendanceProvider, _) {
        final bool isLoading = authProvider.isLoading || attendanceProvider.isLoading || _isRefreshing;
        final User? user = authProvider.user;
        final Attendance? todayAttendance = attendanceProvider.todayAttendance;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(user, isLoading),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildTodayAttendanceCard(todayAttendance, isLoading),
                  _buildQuickActionButtons(),
                  _buildAttendanceSummary(attendanceProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(User? user, bool isLoading) {
    final String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(_currentDate);

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [primaryColor, secondaryColor],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
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
                      const SizedBox(height: 20),
                      isLoading
                          ? _buildShimmerText(24, 200)
                          : Text(
                        'Halo, ${user?.name ?? 'User'}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      isLoading
                          ? _buildShimmerText(14, 150)
                          : Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      isLoading
                          ? _buildShimmerText(16, 250)
                          : Text(
                        'Role: ${user?.role?.toUpperCase() ?? 'Staff'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
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

  Widget _buildShimmerText(double height, double width) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.4),
      highlightColor: Colors.white.withOpacity(0.7),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildTodayAttendanceCard(Attendance? todayAttendance, bool isLoading) {
    String statusText = 'Belum Absen';
    Color statusColor = warningColor;
    IconData statusIcon = Icons.warning_amber_rounded;

    if (!isLoading && todayAttendance != null) {
      if (todayAttendance.checkInTime != null && todayAttendance.checkOutTime != null) {
        statusText = 'Lengkap';
        statusColor = successColor;
        statusIcon = Icons.check_circle_outline;
      } else if (todayAttendance.checkInTime != null) {
        statusText = 'Masuk';
        statusColor = infoColor;
        statusIcon = Icons.login;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? _buildShimmerAttendanceCard()
              : Column(
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Hari Ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _navigateToAttendancePage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Absen'),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildAttendanceTimeInfo(
                      'Masuk',
                      todayAttendance?.checkInTime,
                      todayAttendance?.checkInStatus,
                      Icons.login,
                      successColor,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildAttendanceTimeInfo(
                      'Keluar',
                      todayAttendance?.checkOutTime,
                      todayAttendance?.statusKeluar,
                      Icons.logout,
                      errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAttendanceCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 80,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 90,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 90,
                      height: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTimeInfo(
      String label,
      DateTime? time,
      String? status,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        time != null
            ? Text(
          DateFormat('HH:mm').format(time),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        )
            : Text(
          '-- : --',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[500],
          ),
        ),
        if (status != null && status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionButtons() {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Absensi',
        'icon': Icons.qr_code_scanner,
        'color': infoColor,
        'onTap': _navigateToAttendancePage,
      },
      {
        'title': 'Cuti',
        'icon': Icons.event_busy,
        'color': warningColor,
        'onTap': _navigateToLeaveForm,
      },
      {
        'title': 'Persetujuan',
        'icon': Icons.check_circle,
        'color': successColor,
        'onTap': _navigateToApprovalList,
      },
      {
        'title': 'Riwayat',
        'icon': Icons.history,
        'color': accentColor,
        'onTap': _navigateToAttendanceHistory,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu Cepat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: actions
                    .map((action) => _buildActionButton(
                  action['title'],
                  action['icon'],
                  action['color'],
                  action['onTap'],
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(AttendanceProvider attendanceProvider) {
    // Create summary from attendance history
    final List<Attendance> history = attendanceProvider.attendanceHistory;

    // Process history to get summary counts
    int hadir = 0;
    int izin = 0;
    int cuti = 0;
    int dinas = 0;

    for (var attendance in history) {
      // Assuming attendance has a 'status' field to distinguish types
      String type = attendance.status ?? 'hadir';
      switch (type.toLowerCase()) {
        case 'hadir':
          hadir++;
          break;
        case 'izin':
          izin++;
          break;
        case 'cuti':
          cuti++;
          break;
        case 'dinas':
          dinas++;
          break;
      }
    }

    final List<Map<String, dynamic>> statsList = [
      {'title': 'Hadir', 'value': hadir.toString(), 'color': const Color(0xFF4CAF50)},
      {'title': 'Izin', 'value': izin.toString(), 'color': const Color(0xFFFFA726)},
      {'title': 'Cuti', 'value': cuti.toString(), 'color': const Color(0xFF9575CD)},
      {'title': 'Dinas', 'value': dinas.toString(), 'color': const Color(0xFF4FC3F7)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Bulan Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: Navigate to detailed attendance page
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Detail'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 2.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            physics: const NeverScrollableScrollPhysics(),
            children: statsList
                .map((stat) => _buildStatBox(
              stat['title'],
              stat['value'],
              stat['color'],
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _buildShimmerActivityList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                width: double.infinity,
                height: 16,
                color: Colors.white,
              ),
              subtitle: Container(
                width: double.infinity,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                color: Colors.white,
              ),
              trailing: Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  DateTime parseDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      throw FormatException('Invalid date format: $dateString');
    }
  }


  Widget _buildLegendItem(String title, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator(String label, double value, String percentage, Color color) {
    return Row(
      children: [
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 8.0,
            percent: value,
            backgroundColor: Colors.grey[300],
            progressColor: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerStatistics() {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Container(
    width: 200,
    height: 16,
    color: Colors.white,
    ),
    const SizedBox(height: 24),
    Row(
    children: [
    Container(
    width: 120,
    height: 120,
    decoration: const BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Container(
    width: 100,
    height: 16,
    color: Colors.white,
    ),
    const SizedBox(height: 12),
    Container(
    width: 80,
    height: 16,
    color: Colors.white,
    ),
    const SizedBox(height: 12),
    Container(
    width: 80,
    height: 16,
    color: Colors.white,
    ),
    ],
    ),
    ),
    ],
    ),
    const SizedBox(height: 24),
    const Text(
    'Ketepatan Waktu',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 16),
    Column(
    children: [
    Container(
    width: double.infinity,
    height: 100,
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    const SizedBox(height: 16),
    Container(
    width: double.infinity,
    height: 100,
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    );
  }

