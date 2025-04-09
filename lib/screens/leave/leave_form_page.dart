import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Selected month for filtering
  String? _selectedMonth;
  List<String> _monthOptions = [];

  // Mock data for leave requests
  List<Map<String, dynamic>> _leaveRequests = [];
  List<Map<String, dynamic>> _filteredLeaveRequests = [];

  @override
  void initState() {
    super.initState();
    _generateMonthOptions();
    _generateMockData();
    _filteredLeaveRequests = List.from(_leaveRequests);
  }

  void _generateMonthOptions() {
    final DateTime now = DateTime.now();
    final List<String> options = [];

    // Generate 12 months starting from 11 months ago
    for (int i = -11; i <= 0; i++) {
      final DateTime month = DateTime(now.year, now.month + i, 1);
      final String formattedMonth = DateFormat('MMMM yyyy').format(month);
      options.add(formattedMonth);
    }

    setState(() {
      _monthOptions = options;
      _selectedMonth = DateFormat('MMMM yyyy').format(now); // Default to current month
    });
  }

  void _generateMockData() {
    final List<Map<String, dynamic>> mockData = [
      {
        'id': '1',
        'type': 'Izin',
        'description': 'Urusan keluarga',
        'date': '24 Feb 2025',
        'status': 'Menunggu',
        'month': 'February 2025',
      },
      {
        'id': '2',
        'type': 'Cuti',
        'description': 'Cuti tahunan',
        'date': '10 Jan - 12 Jan 2025',
        'status': 'Disetujui',
        'month': 'January 2025',
      },
      {
        'id': '3',
        'type': 'Sakit',
        'description': 'Demam',
        'date': '05 Dec 2024',
        'status': 'Disetujui',
        'month': 'December 2024',
      },
      {
        'id': '4',
        'type': 'Izin',
        'description': 'Acara keluarga',
        'date': '15 Nov 2024',
        'status': 'Ditolak',
        'month': 'November 2024',
      },
      {
        'id': '5',
        'type': 'Cuti',
        'description': 'Liburan',
        'date': '20 Oct - 25 Oct 2024',
        'status': 'Disetujui',
        'month': 'October 2024',
      },
      {
        'id': '6',
        'type': 'Sakit',
        'description': 'Checkup rutin',
        'date': '08 Sep 2024',
        'status': 'Disetujui',
        'month': 'September 2024',
      },
      {
        'id': '7',
        'type': 'Izin',
        'description': 'Menghadiri seminar',
        'date': '17 Aug 2024',
        'status': 'Menunggu',
        'month': 'August 2024',
      },
      {
        'id': '8',
        'type': 'Cuti',
        'description': 'Cuti bersama',
        'date': '01 Jul - 03 Jul 2024',
        'status': 'Disetujui',
        'month': 'July 2024',
      },
      {
        'id': '9',
        'type': 'Sakit',
        'description': 'Sakit gigi',
        'date': '22 Jun 2024',
        'status': 'Disetujui',
        'month': 'June 2024',
      },
      {
        'id': '10',
        'type': 'Izin',
        'description': 'Mengurus dokumen',
        'date': '12 May 2024',
        'status': 'Ditolak',
        'month': 'May 2024',
      },
      {
        'id': '11',
        'type': 'Cuti',
        'description': 'Liburan keluarga',
        'date': '15 Apr - 20 Apr 2024',
        'status': 'Disetujui',
        'month': 'April 2024',
      },
      {
        'id': '12',
        'type': 'Sakit',
        'description': 'Flu',
        'date': '28 Mar 2024',
        'status': 'Disetujui',
        'month': 'March 2024',
      },
    ];

    setState(() {
      _leaveRequests = mockData;
    });
  }

  void _filterLeaveRequests(String? month) {
    if (month == null) {
      setState(() {
        _filteredLeaveRequests = List.from(_leaveRequests);
      });
      return;
    }

    final filtered = _leaveRequests.where((request) => request['month'] == month).toList();
    setState(() {
      _filteredLeaveRequests = filtered;
    });
  }

  void _showCreateLeaveForm() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateLeaveFormPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Form Izin'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateLeaveForm,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildFilter(),
          Expanded(
            child: _filteredLeaveRequests.isEmpty
                ? _buildEmptyState()
                : _buildLeaveList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: surfaceColor,
      child: Row(
        children: [
          const Text(
            'Filter Bulan:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMonth,
                  hint: const Text('Pilih Bulan'),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _monthOptions.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue;
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
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data izin pada bulan ini',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLeaveRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = _filteredLeaveRequests[index];
        return _buildLeaveItem(request);
      },
    );
  }

  Widget _buildLeaveItem(Map<String, dynamic> leave) {
    Color statusColor;
    Color typeColor;
    IconData typeIcon;

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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    leave['type'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  leave['status'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            leave['description'],
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                leave['date'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}