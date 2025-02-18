import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/absen_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  final AbsenService _absenService = AbsenService();
  String? _name;
  String? _currentDate;
  bool _isLoading = false;
  Map<String, dynamic>? _todayAttendance;
  Map<String, dynamic>? _attendanceStats;

  // Define theme colors to match profile page
  final Color primaryColor = const Color(0xFF64B5F6);
  final Color secondaryColor = const Color(0xFF90CAF9);
  final Color backgroundColor = const Color(0xFFF5F9FF);
  final Color surfaceColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _currentDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadUserData(),
      _loadTodayAttendance(),
      _loadAttendanceHistory(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    final result = await _authService.getUserData();
    if (result['success']) {
      setState(() => _name = result['data']['name']);
    } else {
      setState(() => _name = 'User');
    }
  }

  Future<void> _loadTodayAttendance() async {
    final result = await _absenService.getAbsenToday();
    if (result['success']) {
      setState(() => _todayAttendance = result);
    }
  }

  Future<void> _loadAttendanceHistory() async {
    final result = await _absenService.getAttendanceHistory();
    if (result['success']) {
      setState(() => _attendanceStats = result['data']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAttendanceSummary(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Selamat Datang,\n${_name ?? 'User'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentDate ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            // TODO: Navigate to profile page
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAttendanceSummary() {
    // Use real attendance stats from API
    final stats = _attendanceStats?['summary'] ?? {
      'hadir': 0,
      'izin': 0,
      'alpha': 0,
    };

    final List<Map<String, dynamic>> statsList = [
      {'title': 'Hadir', 'value': stats['hadir'].toString(), 'color': const Color(0xFF4CAF50)},
      {'title': 'Izin', 'value': stats['izin'].toString(), 'color': const Color(0xFFFFA726)},
      {'title': 'Alpha', 'value': stats['alpha'].toString(), 'color': const Color(0xFFE57373)},
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
                'Ringkasan Absensi',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  Widget _buildRecentActivity() {
    final checkIn = _todayAttendance?['data']?['masuk'];
    final checkOut = _todayAttendance?['data']?['keluar'];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas Terakhir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (checkIn != null) ...[
            _buildActivityItem(
              'Check-in',
              DateFormat('HH:mm').format(DateTime.parse(checkIn['created_at'])),
              checkIn['status'] ?? 'Tepat Waktu',
              Icons.login_rounded,
              _getStatusColor(checkIn['status']),
            ),
            const SizedBox(height: 12),
          ],
          if (checkOut != null)
            _buildActivityItem(
              'Check-out',
              DateFormat('HH:mm').format(DateTime.parse(checkOut['created_at'])),
              checkOut['status'] ?? 'Tepat Waktu',
              Icons.logout_rounded,
              _getStatusColor(checkOut['status']),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'terlambat':
        return const Color(0xFFFFA726);
      case 'tepat waktu':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  Widget _buildStatBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      String title,
      String time,
      String status,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}