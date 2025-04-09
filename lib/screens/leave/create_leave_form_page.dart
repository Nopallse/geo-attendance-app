import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateLeaveFormPage extends StatefulWidget {

  const CreateLeaveFormPage({super.key});
  @override
  State<CreateLeaveFormPage> createState() => _CreateLeaveFormPageState();
}

class _CreateLeaveFormPageState extends State<CreateLeaveFormPage> {
  String? _leaveType;
  String? _leaveCategory;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _startDate;
  DateTime? _endDate;
  TextEditingController _descriptionController = TextEditingController();

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _pickTime(bool isStart) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengajuan Izin')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilih Jenis Izin
            Text('Jenis Izin:'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: Text('Izin Jam'),
                    value: 'jam',
                    groupValue: _leaveType,
                    onChanged: (value) {
                      setState(() {
                        _leaveType = value.toString();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: Text('Izin Hari'),
                    value: 'hari',
                    groupValue: _leaveType,
                    onChanged: (value) {
                      setState(() {
                        _leaveType = value.toString();
                      });
                    },
                  ),
                ),
              ],
            ),

            // Kategori Izin
            DropdownButtonFormField<String>(
              value: _leaveCategory,
              hint: Text('Pilih Kategori Izin'),
              onChanged: (value) {
                setState(() {
                  _leaveCategory = value;
                });
              },
              items: ['Izin', 'Cuti', 'Sakit', 'Dinas'].map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
            ),

            SizedBox(height: 16),

            // Durasi Izin
            if (_leaveType == 'jam') ...[
              Text('Pilih Tanggal:'),
              ElevatedButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? 'Pilih Tanggal'
                    : DateFormat('dd MMM yyyy').format(_selectedDate!)),
              ),
              Text('Jam Mulai - Selesai:'),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickTime(true),
                    child: Text(_startTime == null
                        ? 'Pilih Jam Mulai'
                        : _startTime!.format(context)),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _pickTime(false),
                    child: Text(_endTime == null
                        ? 'Pilih Jam Selesai'
                        : _endTime!.format(context)),
                  ),
                ],
              ),
            ] else if (_leaveType == 'hari') ...[
              Text('Pilih Rentang Tanggal:'),
              ElevatedButton(
                onPressed: _pickDateRange,
                child: Text(_startDate == null || _endDate == null
                    ? 'Pilih Rentang Tanggal'
                    : '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'),
              ),
            ],

            SizedBox(height: 16),

            // Keterangan
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 16),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Simpan data izin
                },
                child: Text('Ajukan Izin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
