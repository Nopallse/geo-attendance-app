import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/attendance_provider.dart';
import '../../data/models/attendance_model.dart';
import '../../styles/colors.dart';
import '../../styles/theme.dart';
import '../../styles/typography.dart';
import '../../widgets/widgets.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat',
          style: AppTypography.headline4.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,

      ),
      body: Column(
        children: [
          FilterSection(
            selectedMonth: _selectedMonth,
            selectedFilter: _selectedFilter,
            filterOptions: _filterOptions,
            onMonthSelected: _onMonthChanged,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.attendanceHistory.isEmpty) {
                  return const ShimmerLoading();
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: provider.attendanceHistory.isEmpty && !provider.isLoading
                      ? EmptyState(onRefresh: _onRefresh)
                      : _buildAttendanceList(provider),
                );
              },
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
          AttendanceCard(
            index: index,
            date: date,
            attendance: attendance,
            isExpanded: _expandedItems[index] ?? false,
            onToggleExpansion: () => _toggleItemExpansion(index),
          ),
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
              Icon(Icons.filter_alt_off, size: 48, color: AppColors.textHint),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data untuk filter "$_selectedFilter"',
                style: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),
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
                  colors: [AppColors.white.withOpacity(0), AppColors.white],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}