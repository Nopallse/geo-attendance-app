import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';
import '../../providers/leave_provider.dart';
import '../../data/models/leave_model.dart';
import '../../styles/colors.dart';
import 'create_leave_form_page.dart';

class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({super.key});

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  // Selected year for filtering
  String? _selectedYear;
  List<String> _yearOptions = [];

  @override
  void initState() {
    super.initState();
    _generateYearOptions();
    // Schedule the data loading after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaves();
    });
  }

  void _generateYearOptions() {
    final DateTime now = DateTime.now();
    final List<String> options = [];

    // Generate years (current and two previous years)
    for (int i = -2; i <= 0; i++) {
      final int year = now.year + i;
      options.add(year.toString());
    }

    setState(() {
      _yearOptions = options;
      _selectedYear = now.year.toString(); // Default to current year
    });
  }

  Future<void> _loadLeaves() async {
    final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
    await leaveProvider.getLeaves(page: 1, limit: 10);
  }

  void _showCreateLeaveForm() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateLeaveFormPage()));
  }

  String _getDateRangeText(DateTime startDate, DateTime endDate) {
    final formatter = DateFormat('d MMM');
    final yearFormatter = DateFormat('yyyy');

    if (startDate.isAtSameMomentAs(endDate)) {
      return formatter.format(startDate) + ' ' + yearFormatter.format(startDate);
    } else if (startDate.month == endDate.month && startDate.year == endDate.year) {
      return '${DateFormat('d').format(startDate)} - ${formatter.format(endDate)} ${yearFormatter.format(endDate)}';
    } else {
      return '${formatter.format(startDate)} - ${formatter.format(endDate)} ${yearFormatter.format(endDate)}';
    }
  }

  String _getGroupMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Riwayat Cuti & Izin',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateLeaveForm,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajukan Izin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildYearFilter(),
          Expanded(
            child: Consumer<LeaveProvider>(
              builder: (context, leaveProvider, _) {
                if (leaveProvider.isLoading && leaveProvider.leaves.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (leaveProvider.error != null && leaveProvider.leaves.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan: ${leaveProvider.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadLeaves,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (leaveProvider.leaves.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildGroupedLeaveList(leaveProvider.leaves);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Text(
            'Pilih Tahun: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
                color: AppColors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedYear,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items: _yearOptions.map<DropdownMenuItem<String>>((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYear = newValue;
                    });
                    _loadLeaves();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 100,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada riwayat izin untuk tahun $_selectedYear',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik tombol "+ Ajukan Izin" untuk membuat permohonan baru',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedLeaveList(List<LeaveModel> leaves) {
    // Filter leaves by selected year
    final filteredLeaves = leaves.where((leave) {
      return leave.startDate.year.toString() == _selectedYear;
    }).toList();

    if (filteredLeaves.isEmpty) {
      return _buildEmptyState();
    }

    return GroupedListView<LeaveModel, String>(
      elements: filteredLeaves,
      groupBy: (element) => _getGroupMonth(element.startDate),
      groupComparator: (value1, value2) {
        // Sort groups in reverse chronological order (newest first)
        final date1 = DateFormat('MMMM yyyy').parse(value1);
        final date2 = DateFormat('MMMM yyyy').parse(value2);
        return date2.compareTo(date1);
      },
      itemComparator: (item1, item2) {
        // Sort items in reverse chronological order (newest first)
        return item2.startDate.compareTo(item1.startDate);
      },
      order: GroupedListOrder.ASC,
      useStickyGroupSeparators: true,
      groupSeparatorBuilder: (String value) => Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  color: AppColors.divider,
                  thickness: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 80), // Extra padding for FAB
      itemBuilder: (context, leave) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: _buildLeaveItem(leave),
        );
      },
    );
  }

  Widget _buildLeaveItem(LeaveModel leave) {
    Color statusColor;
    Color typeColor;
    IconData typeIcon;
    final bool isHourlyLeave = leave.startDate.hour != 0 || leave.endDate.hour != 0;

    final dateRange = _getDateRangeText(leave.startDate, leave.endDate);

    // Set status color
    switch (leave.status) {
      case 'approved':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'rejected':
        statusColor = const Color(0xFFE57373);
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFFFA726);
    }

    // Set type color and icon
    switch (leave.category) {
      case 'Cuti':
        typeColor = const Color(0xFF9575CD);
        typeIcon = Icons.beach_access;
        break;
      case 'Sakit':
        typeColor = const Color(0xFFE57373);
        typeIcon = Icons.healing;
        break;
      case 'Izin':
      default:
        typeColor = const Color(0xFFFFA726);
        typeIcon = Icons.event_busy;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // View detail - could be implemented in the future
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              leave.category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isHourlyLeave
                                    ? const Color(0xFF64B5F6).withOpacity(0.1)
                                    : const Color(0xFF81C784).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isHourlyLeave ? 'Jam' : 'Hari',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isHourlyLeave
                                      ? const Color(0xFF1976D2)
                                      : const Color(0xFF388E3C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leave.description ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateRange,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (isHourlyLeave) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${DateFormat('HH:mm').format(leave.startDate)} - ${DateFormat('HH:mm').format(leave.endDate)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(leave.status),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu';
    }
  }
}