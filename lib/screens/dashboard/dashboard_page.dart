import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/office_provider.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/user_model.dart';
import '../leave/leave_form_page.dart';
import '../../styles/colors.dart';
import '../../widgets/widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DateTime _currentDate;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final officeProvider = Provider.of<OfficeProvider>(context, listen: false);

    // Get user profile if not loaded
    if (authProvider.user == null) {
      await authProvider.getUserProfile();
    }

    await Future.wait([
      authProvider.user == null ? authProvider.getUserProfile() : Future.value(null),
      attendanceProvider.getTodayAttendance(),
      attendanceProvider.getAttendanceHistory(refresh: true),
      officeProvider.offices.isEmpty ? officeProvider.getOffices() : Future.value(null),
    ]);
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

  void _navigateToLeaveForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaveFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
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
            AppHeader(
              currentDate: _currentDate,
              user: user,
              isLoading: isLoading,
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AttendanceSummary(
                      todayAttendance: todayAttendance,
                      isLoading: isLoading
                  ),
                  LeaveButton(onPressed: _navigateToLeaveForm),
                  AttendanceStatsGrid(attendanceProvider: attendanceProvider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}