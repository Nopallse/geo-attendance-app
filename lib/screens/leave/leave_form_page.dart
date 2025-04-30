import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'create_leave_form_page.dart';

class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({super.key});

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  final Color primaryColor = const Color(0xFF64B5F6);
  final Color secondaryColor = const Color(0xFF90CAF9);
  final Color backgroundColor = const Color(0xFFF5F9FF);
  final Color surfaceColor = Colors.white;

  // Selected year for filtering
  String? _selectedYear;
  List<String> _yearOptions = [];

  // Mock data for leave requests
  List<Map<String, dynamic>> _leaveRequests = [];
  List<Map<String, dynamic>> _filteredLeaveRequests = [];

  @override
  void initState() {
    super.initState();
    _generateYearOptions();
    _generateMockData();
    _filterLeaveRequests(_selectedYear);
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

  void _generateMockData() {
    final List<Map<String, dynamic>> mockData = [
      {
        'id': '1',
        'type': 'Izin',
        'leaveType': 'jam',
        'description': 'Urusan keluarga',
        'start_date': DateTime(2025, 2, 24),
        'end_date': DateTime(2025, 2, 24),
        'start_time': '09:00',
        'end_time': '12:00',
        'status': 'Menunggu',
      },
      {
        'id': '2',
        'type': 'Cuti',
        'leaveType': 'hari',
        'description': 'Cuti tahunan',
        'start_date': DateTime(2025, 1, 10),
        'end_date': DateTime(2025, 1, 12),
        'status': 'Disetujui',
      },
      {
        'id': '3',
        'type': 'Sakit',
        'leaveType': 'hari',
        'description': 'Demam',
        'start_date': DateTime(2024, 12, 5),
        'end_date': DateTime(2024, 12, 5),
        'status': 'Disetujui',
      },
      {
        'id': '4',
        'type': 'Izin',
        'leaveType': 'jam',
        'description': 'Acara keluarga',
        'start_date': DateTime(2024, 11, 15),
        'end_date': DateTime(2024, 11, 15),
        'start_time': '13:00',
        'end_time': '17:00',
        'status': 'Ditolak',
      },
      {
        'id': '5',
        'type': 'Cuti',
        'leaveType': 'hari',
        'description': 'Liburan',
        'start_date': DateTime(2024, 10, 20),
        'end_date': DateTime(2024, 10, 25),
        'status': 'Disetujui',
      },
      {
        'id': '6',
        'type': 'Sakit',
        'leaveType': 'jam',
        'description': 'Checkup rutin',
        'start_date': DateTime(2024, 9, 8),
        'end_date': DateTime(2024, 9, 8),
        'start_time': '10:00',
        'end_time': '12:30',
        'status': 'Disetujui',
      },
      {
        'id': '7',
        'type': 'Izin',
        'leaveType': 'hari',
        'description': 'Menghadiri seminar',
        'start_date': DateTime(2024, 8, 17),
        'end_date': DateTime(2024, 8, 17),
        'status': 'Menunggu',
      },
      {
        'id': '8',
        'type': 'Cuti',
        'leaveType': 'hari',
        'description': 'Cuti bersama',
        'start_date': DateTime(2024, 7, 1),
        'end_date': DateTime(2024, 7, 3),
        'status': 'Disetujui',
      },
      {
        'id': '9',
        'type': 'Sakit',
        'leaveType': 'jam',
        'description': 'Sakit gigi',
        'start_date': DateTime(2024, 6, 22),
        'end_date': DateTime(2024, 6, 22),
        'start_time': '08:00',
        'end_time': '11:00',
        'status': 'Disetujui',
      },
      {
        'id': '10',
        'type': 'Izin',
        'leaveType': 'jam',
        'description': 'Mengurus dokumen',
        'start_date': DateTime(2024, 5, 12),
        'end_date': DateTime(2024, 5, 12),
        'start_time': '14:00',
        'end_time': '16:00',
        'status': 'Ditolak',
      },
      {
        'id': '11',
        'type': 'Cuti',
        'leaveType': 'hari',
        'description': 'Liburan keluarga',
        'start_date': DateTime(2024, 4, 15),
        'end_date': DateTime(2024, 4, 20),
        'status': 'Disetujui',
      },
      {
        'id': '12',
        'type': 'Sakit',
        'leaveType': 'hari',
        'description': 'Flu',
        'start_date': DateTime(2024, 3, 28),
        'end_date': DateTime(2024, 3, 28),
        'status': 'Disetujui',
      },
      {
        'id': '13',
        'type': 'Izin',
        'leaveType': 'jam',
        'description': 'Pengurusan SIM',
        'start_date': DateTime(2023, 12, 5),
        'end_date': DateTime(2023, 12, 5),
        'start_time': '09:00',
        'end_time': '11:30',
        'status': 'Disetujui',
      },
      {
        'id': '14',
        'type': 'Cuti',
        'leaveType': 'hari',
        'description': 'Cuti akhir tahun',
        'start_date': DateTime(2023, 12, 27),
        'end_date': DateTime(2023, 12, 30),
        'status': 'Disetujui',
      },
    ];

    setState(() {
      _leaveRequests = mockData;
    });
  }

  void _filterLeaveRequests(String? year) {
    if (year == null) {
      setState(() {
        _filteredLeaveRequests = List.from(_leaveRequests);
      });
      return;
    }

    final filtered = _leaveRequests.where((request) {
      final startDate = request['start_date'] as DateTime;
      return startDate.year.toString() == year;
    }).toList();

    setState(() {
      _filteredLeaveRequests = filtered;
    });
  }

  void _showCreateLeaveForm() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateLeaveFormPage()));
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Riwayat Cuti & Izin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateLeaveForm,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Ajukan Izin'),
        elevation: 4,
      ),
      body: Column(
        children: [
          _buildYearFilter(),
          Expanded(
            child: _filteredLeaveRequests.isEmpty
                ? _buildEmptyState()
                : _buildGroupedLeaveList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Text(
            'Pilih Tahun: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                color: surfaceColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedYear,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  style: TextStyle(
                    color: Colors.grey.shade800,
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
                    _filterLeaveRequests(newValue);
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
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada riwayat izin untuk tahun $_selectedYear',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Klik tombol "+ Ajukan Izin" untuk membuat permohonan baru',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedLeaveList() {
    return GroupedListView<Map<String, dynamic>, String>(
      elements: _filteredLeaveRequests,
      groupBy: (element) => _getGroupMonth(element['start_date']),
      groupComparator: (value1, value2) {
        // Sort groups in reverse chronological order (newest first)
        final date1 = DateFormat('MMMM yyyy').parse(value1);
        final date2 = DateFormat('MMMM yyyy').parse(value2);
        return date2.compareTo(date1);
      },
      itemComparator: (item1, item2) {
        // Sort items in reverse chronological order (newest first)
        return item2['start_date'].compareTo(item1['start_date']);
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
                color: secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 80), // Extra padding for FAB
      itemBuilder: (context, element) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: _buildLeaveItem(element),
        );
      },
    );
  }

  Widget _buildLeaveItem(Map<String, dynamic> leave) {
    Color statusColor;
    Color typeColor;
    IconData typeIcon;
    final bool isHourlyLeave = leave['leaveType'] == 'jam';

    final dateRange = _getDateRangeText(
      leave['start_date'],
      leave['end_date'],
    );

    // Set status color
    switch (leave['status']) {
      case 'Disetujui':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'Ditolak':
        statusColor = const Color(0xFFE57373);
        break;
      case 'Menunggu':
      default:
        statusColor = const Color(0xFFFFA726);
    }

    // Set type color and icon
    switch (leave['type']) {
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
          color: Colors.grey.shade100,
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
                              leave['type'],
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
                          leave['description'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
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
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateRange,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
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
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${leave['start_time']} - ${leave['end_time']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
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
                      leave['status'],
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
}