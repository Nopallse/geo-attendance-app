import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/attendance_provider.dart';
import '../../data/models/attendance_model.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedMonth = DateTime.now();
  List<DateTime> _allDatesInMonth = [];
  String _selectedFilter = 'Semua';
  List<String> _filterOptions = ['Semua', 'Hadir', 'Tidak Hadir', 'Terlambat'];
  Map<int, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _generateAllDatesInMonth();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendanceHistory(true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<AttendanceProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!provider.isLoading && provider.hasMoreData) {
        _loadAttendanceHistory(false);
      }
    }
  }

  Future<void> _loadAttendanceHistory(bool refresh) async {
    await Provider.of<AttendanceProvider>(context, listen: false)
        .getAttendanceHistory(refresh: refresh);
  }

  Future<void> _onRefresh() async {
    await _loadAttendanceHistory(true);
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
      _generateAllDatesInMonth();
      // Reset expanded items
      _expandedItems = {};
    });
    _loadAttendanceHistory(true);
  }

  void _toggleItemExpansion(int index) {
    setState(() {
      _expandedItems[index] = !(_expandedItems[index] ?? false);
    });
  }

  bool _shouldShowItem(Attendance? attendance) {
    if (_selectedFilter == 'Semua') return true;
    if (attendance == null) return _selectedFilter == 'Tidak Hadir';

    final status = attendance.status?.toLowerCase() ?? '';
    final isLate = attendance.checkInStatus?.toLowerCase() == 'telat';

    if (_selectedFilter == 'Hadir') return status == 'hadir';
    if (_selectedFilter == 'Tidak Hadir') return status == 'tidak hadir' || status.isEmpty;
    if (_selectedFilter == 'Terlambat') return isLate;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.attendanceHistory.isEmpty) {
                  return _buildShimmerLoading();
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: provider.attendanceHistory.isEmpty && !provider.isLoading
                      ? _buildEmptyState()
                      : _buildAttendanceList(provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blue),
            onPressed: () => _showMonthPicker(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  items: _filterOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _onRefresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(AttendanceProvider provider) {
    List<Widget> filteredItems = [];

    for (int index = 0; index < _allDatesInMonth.length; index++) {
      final date = _allDatesInMonth[index];
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Find attendance for this date
      Attendance? attendance;
      for (var item in provider.attendanceHistory) {
        if (item.tanggal != null) {
          final attendanceDate = DateFormat('yyyy-MM-dd').format(item.tanggal!);
          if (attendanceDate == formattedDate) {
            attendance = item;
            break;
          }
        }
      }

      // Apply filter
      if (_shouldShowItem(attendance)) {
        filteredItems.add(
          _buildAttendanceCard(index, date, attendance),
        );
      }
    }

    return Stack(
      children: [
        filteredItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_alt_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data untuk filter "$_selectedFilter"',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        )
            : ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: filteredItems,
        ),
        if (provider.isLoading && provider.attendanceHistory.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withOpacity(0), Colors.white],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendanceCard(int index, DateTime date, Attendance? attendance) {
    final bool isExpanded = _expandedItems[index] ?? false;
    final bool hasAttendance = attendance != null;
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    final bool isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    Color cardColor;
    if (isToday) {
      cardColor = Colors.blue[50]!;
    } else if (hasAttendance) {
      cardColor = Colors.white;
    } else if (isPast) {
      cardColor = Colors.grey[200]!;
    } else {
      cardColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _toggleItemExpansion(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: hasAttendance
              ? Border.all(color: Colors.blue[100]!)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE', 'id_ID').format(date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy', 'id_ID').format(date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!isExpanded && hasAttendance) ...[
                          const SizedBox(height: 8),
                          _buildCompactAttendanceInfo(attendance!),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded && hasAttendance)
              _buildExpandedAttendanceDetails(attendance!),
            if (!hasAttendance && isExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Text(
                  isPast ? 'Tidak ada rekaman absensi untuk tanggal ini' : 'Belum ada rekaman absensi',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildCompactAttendanceInfo(Attendance attendance) {
    final DateTime? checkInTime = attendance.checkInTime;
    final DateTime? checkOutTime = attendance.checkOutTime;
    final bool isLate = attendance.checkInStatus?.toLowerCase() == 'telat';
    final bool isEarlyOut = attendance.checkOutStatus?.toLowerCase() == 'pulang_awal';

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.login_rounded,
                size: 14,
                color: isLate ? Colors.red[400] : Colors.green[400],
              ),
              const SizedBox(width: 4),
              Text(
                checkInTime != null ? DateFormat('HH:mm').format(checkInTime) : '-',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isLate ? Colors.red[700] : Colors.green[700],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 14,
                color: isEarlyOut ? Colors.orange[400] : Colors.blue[400],
              ),
              const SizedBox(width: 4),
              Text(
                checkOutTime != null ? DateFormat('HH:mm').format(checkOutTime) : '-',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isEarlyOut ? Colors.orange[700] : Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(attendance.status ?? 'tidak hadir', small: true),
      ],
    );
  }

  Widget _buildExpandedAttendanceDetails(Attendance attendance) {
    final DateTime? checkInTime = attendance.checkInTime;
    final DateTime? checkOutTime = attendance.checkOutTime;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Masuk',
                  checkInTime,
                  attendance.checkInStatus == 'telat',
                  Icons.login_rounded,
                  attendance.checkInStatus,
                ),
              ),
              Container(
                height: 70,
                width: 1,
                color: Colors.grey[200],
              ),
              Expanded(
                child: _buildTimeInfo(
                  'Keluar',
                  checkOutTime,
                  attendance.checkOutStatus == 'pulang_awal',
                  Icons.logout_rounded,
                  attendance.checkOutStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusBadge(attendance.status ?? 'tidak hadir'),
            ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
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
          if (status != null && status.isNotEmpty) ...[
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
    switch (status.toLowerCase()) {
      case 'telat':
        return 'Terlambat';
      case 'pulang_awal':
        return 'Pulang Awal';
      case 'normal':
        return 'Tepat Waktu';
      case 'hadir':
        return 'Hadir';
      case 'tidak hadir':
        return 'Tidak Hadir';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildStatusBadge(String status, {bool small = false}) {
    final isPresent = status.toLowerCase() == 'hadir';
    final backgroundColor =
    (isPresent ? Colors.green[400] : Colors.red[400])!.withOpacity(0.1);
    final textColor = isPresent ? Colors.green[700] : Colors.red[700];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 12,
        vertical: small ? 2 : 6,
      ),
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
            size: small ? 10 : 16,
          ),
          SizedBox(width: small ? 2 : 4),
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: textColor,
              fontSize: small ? 10 : 12,
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih Bulan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              SizedBox(
                height: 300,
                width: double.maxFinite,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: 12,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final month = DateTime.now().subtract(Duration(days: 30 * index));
                    final isSelected = _selectedMonth.month == month.month &&
                        _selectedMonth.year == month.year;

                    return ListTile(
                      title: Text(
                        DateFormat('MMMM yyyy', 'id_ID').format(month),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue[700] : Colors.black87,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: Colors.blue[50],
                      onTap: () {
                        _onMonthChanged(month);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}