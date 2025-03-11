import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/absen_service.dart';
import '../leave/leave_form_page.dart';
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
      setState(() => _todayAttendance = result);
  }

  Future<void> _loadAttendanceHistory() async {
    final result = await _absenService.getAttendanceHistory();
    if (result['success']) {
      setState(() => _attendanceStats = result['data']);
    }
  }

  void _navigateToLeaveForm() {
     Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveFormPage()));
  }

  void _navigateToApprovalList() {
    // TODO: Navigate to leave approval list page
    // Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveApprovalPage()));
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
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildAttendanceSummary(),
                  const SizedBox(height: 24),
                  _buildApprovalSection(),
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

  Widget _buildQuickActions() {
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
            'Akses Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                'Izin/Cuti',
                Icons.edit_document,
                const Color(0xFF42A5F5),
                _navigateToLeaveForm,
              ),
              _buildQuickActionButton(
                'Persetujuan',
                Icons.approval,
                const Color(0xFF66BB6A),
                _navigateToApprovalList,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    // Use real attendance stats from API with updated categories
    final stats = _attendanceStats?['summary'] ?? {
      'hadir': 0,
      'izin': 0,
      'cuti': 0,
      'dinas': 0,
    };

    final List<Map<String, dynamic>> statsList = [
      {'title': 'Hadir', 'value': stats['hadir'].toString(), 'color': const Color(0xFF4CAF50)},
      {'title': 'Izin', 'value': stats['izin'].toString(), 'color': const Color(0xFFFFA726)},
      {'title': 'Cuti', 'value': stats['cuti'].toString(), 'color': const Color(0xFF9575CD)},
      {'title': 'Dinas', 'value': stats['dinas'].toString(), 'color': const Color(0xFF4FC3F7)},
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

  Widget _buildApprovalSection() {
    // Mock data for pending approvals - replace with actual API data
    final List<Map<String, dynamic>> pendingApprovals = [
      {
        'name': 'Ahmad Rizky',
        'type': 'Izin',
        'date': '24 Feb 2025',
        'status': 'Menunggu',
      },
      {
        'name': 'Dewi Putri',
        'type': 'Cuti',
        'date': '25 Feb - 28 Feb 2025',
        'status': 'Menunggu',
      },
    ];

    return pendingApprovals.isEmpty
        ? const SizedBox.shrink()
        : Container(
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
                'Persetujuan Izin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _navigateToApprovalList,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Semua'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...pendingApprovals.map((approval) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildApprovalItem(approval),
          )),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(Map<String, dynamic> approval) {
    Color typeColor;
    IconData typeIcon;

    switch (approval['type']) {
      case 'Izin':
        typeColor = const Color(0xFFFFA726);
        typeIcon = Icons.event_busy;
        break;
      case 'Cuti':
        typeColor = const Color(0xFF9575CD);
        typeIcon = Icons.beach_access;
        break;
      case 'Dinas':
        typeColor = const Color(0xFF4FC3F7);
        typeIcon = Icons.business_center;
        break;
      default:
        typeColor = const Color(0xFF9E9E9E);
        typeIcon = Icons.event_note;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approval['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${approval['type']} - ${approval['date']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50)),
                onPressed: () {
                  // TODO: Implement approval action
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, color: Color(0xFFE57373)),
                onPressed: () {
                  // TODO: Implement rejection action
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}