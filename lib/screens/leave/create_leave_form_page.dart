import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/leave_provider.dart';

class CreateLeaveFormPage extends StatefulWidget {
  const CreateLeaveFormPage({super.key});

  @override
  State<CreateLeaveFormPage> createState() => _CreateLeaveFormPageState();
}

class _CreateLeaveFormPageState extends State<CreateLeaveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFF64B5F6);
  final Color secondaryColor = const Color(0xFF90CAF9);
  final Color backgroundColor = const Color(0xFFF5F9FF);
  final Color surfaceColor = Colors.white;

  String? _leaveCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _categories = ['Izin', 'Cuti', 'Sakit', 'Dinas'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _pickDateRange() async {
    final DateTime now = DateTime.now();
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  bool _validateForm() {
    return _leaveCategory != null && _startDate != null && _endDate != null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _validateForm()) {
      setState(() {
        _isSubmitting = true;
      });

      final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);

      final success = await leaveProvider.createLeave(
        startDate: _startDate!,
        endDate: _endDate!,
        category: _leaveCategory!,
        description: _descriptionController.text,
      );

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permohonan izin berhasil diajukan!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(leaveProvider.error ?? 'Terjadi kesalahan saat mengajukan izin'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Harap lengkapi semua field yang diperlukan'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pengajuan Izin',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),

        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Set back button color to white

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection Card
                  _buildSectionCard(
                    title: 'Kategori Izin',
                    child: _buildCategoryDropdown(),
                  ),

                  const SizedBox(height: 16),

                  // Date Selection Card
                  _buildSectionCard(
                    title: 'Rentang Tanggal',
                    child: _buildDaySelection(),
                  ),

                  const SizedBox(height: 16),

                  // Description Card
                  _buildSectionCard(
                    title: 'Keterangan',
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Tulis alasan atau keterangan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Keterangan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Ajukan Permohonan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _leaveCategory,
      hint: const Text('Pilih Kategori'),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _leaveCategory = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Harap pilih kategori';
        }
        return null;
      },
    );
  }

  Widget _buildDaySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Rentang Tanggal:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickDateRange,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.date_range,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _startDate == null || _endDate == null
                        ? 'Tap untuk memilih tanggal'
                        : '${DateFormat('d MMM yyyy').format(_startDate!)} - ${DateFormat('d MMM yyyy').format(_endDate!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: _startDate == null || _endDate == null
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                ),
                if (_startDate != null && _endDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_endDate!.difference(_startDate!).inDays + 1} hari',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}