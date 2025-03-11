import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:absensi_app/services/absen_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final AbsenService _absenService = AbsenService();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _attendanceList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 10;
  DateTime _selectedMonth = DateTime.now();
  List<DateTime> _allDatesInMonth = [];

  @override
  void initState() {
    super.initState();
    _loadAttendanceHistory();
    _scrollController.addListener(_onScroll);
    _generateAllDatesInMonth();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadAttendanceHistory();
      }
    }
  }

  Future<void> _loadAttendanceHistory() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _absenService.getAttendanceHistory(
        page: _currentPage,
        limit: _limit,
        // month: _selectedMonth.month,
        // year: _selectedMonth.year,
      );
      if (result['success']) {
        setState(() {
          if (_currentPage == 1) {
            _attendanceList = result['data']['data'];
          } else {
            _attendanceList.addAll(result['data']['data']);
          }
          _hasMore = result['data']['pagination']['currentPage'] <
              result['data']['pagination']['totalPages'];
          _currentPage++;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat memuat data')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _attendanceList.clear();
    });
    await _loadAttendanceHistory();
  }

  void _generateAllDatesInMonth() {
    final DateTime firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final DateTime lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    _allDatesInMonth = List<DateTime>.generate(
      lastDay.day,
          (index) => DateTime(firstDay.year, firstDay.month, index + 1),
    );
  }

  void _onMonthChanged(DateTime newMonth) {
    setState(() {
      _selectedMonth = newMonth;
      _currentPage = 1;
      _hasMore = true;
      _attendanceList.clear();
      _generateAllDatesInMonth();
    });
    _loadAttendanceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black87),
            onPressed: () => _showMonthPicker(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _attendanceList.isEmpty && !_isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                size: 64,
                color: Colors.blue[200],
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum ada riwayat absensi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _allDatesInMonth.length,
          itemBuilder: (context, index) {
            final date = _allDatesInMonth[index];
            final attendance = _attendanceList.firstWhere(
                  (element) => DateFormat('yyyy-MM-dd').format(DateTime.parse(element['jam_masuk'])) == DateFormat('yyyy-MM-dd').format(date),
              orElse: () => null,
            );

            return _buildAttendanceCard(date, attendance);
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(DateTime date, Map<String, dynamic>? attendance) {
    final DateTime? jamMasuk = attendance != null ? DateTime.parse(attendance['jam_masuk']) : null;
    final DateTime? jamKeluar = attendance != null && attendance['jam_keluar'] != null
        ? DateTime.parse(attendance['jam_keluar'])
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
    Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.blue[100]!.withOpacity(0.3),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
    children: [
    Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
    Icons.calendar_today_rounded,
    color: Colors.blue[400],
    size: 20,
    ),
    ),
    const SizedBox(width: 12),
    Text(
    DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date),
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    ),
    ),
    ],
    ),
    ),
    if (attendance != null)
    Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    children: [
    Row(
    children: [
    Expanded(
    child: _buildTimeInfo(
    'Masuk',
    jamMasuk,
    attendance['status_masuk'] == 'telat',
    Icons.login_rounded,
    attendance['status_masuk'],
    ),
    ),
    Container(
    height: 40,
    width: 1,
    color: Colors.grey[200],
    ),
    Expanded(
    child: _buildTimeInfo(
    'Keluar',
    jamKeluar,
    attendance['status_keluar'] == 'pulang_awal',
    Icons.logout_rounded,
    attendance['status_keluar'],
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),
    _buildStatusBadge(attendance['status']),
    ],
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildTimeInfo(
      String label,
      DateTime? time,
      bool isLate,
      IconData icon,
      String? status,
      ) {
    final color = time == null
        ? Colors.grey
        : (isLate ? Colors.red[400] : Colors.green[400]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time != null ? DateFormat('HH:mm:ss').format(time) : '-',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (status != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatStatus(status),
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'telat':
        return 'Terlambat';
      case 'pulang_awal':
        return 'Pulang Awal';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildStatusBadge(String status) {
    final isPresent = status.toLowerCase() == 'hadir';
    final backgroundColor =
    (isPresent ? Colors.green[400] : Colors.red[400])!.withOpacity(0.1);
    final textColor = isPresent ? Colors.green[700] : Colors.red[700];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPresent ? Icons.check_circle : Icons.warning_rounded,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Bulan'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (context, index) {
                final month = DateTime.now().subtract(Duration(days: 30 * index));
                return ListTile(
                  title: Text(DateFormat('MMMM yyyy', 'id_ID').format(month)),
                  onTap: () {
                    _onMonthChanged(month);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}