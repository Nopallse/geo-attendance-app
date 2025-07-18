class LateArrivalRequest {
  final int id;
  final String userNip;
  final DateTime tanggalTerlambat;
  final String jamDatangRencana;
  final String alasan;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LateArrivalRequest({
    required this.id,
    required this.userNip,
    required this.tanggalTerlambat,
    required this.jamDatangRencana,
    required this.alasan,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory LateArrivalRequest.fromJson(Map<String, dynamic> json) {
    try {
      return LateArrivalRequest(
        id: _parseId(json['id']),
        userNip: _parseString(json['user_nip']),
        tanggalTerlambat: _parseDateTime(json['tanggal_terlambat']),
        jamDatangRencana: _parseString(json['jam_datang_rencana']),
        alasan: _parseString(json['alasan']),
        status: _parseString(json['status'], defaultValue: 'pending'),
        approvedBy: json['approved_by']?.toString(),
        approvedAt: _parseNullableDateTime(json['approved_at']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseNullableDateTime(json['updated_at']),
      );
    } catch (e) {
      throw FormatException('Failed to parse LateArrivalRequest: $e, json: $json');
    }
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        throw FormatException('Invalid date format: $value');
      }
    }
    throw FormatException('Expected string for date, got: $value');
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_nip': userNip,
      'tanggal_terlambat': tanggalTerlambat.toIso8601String().split('T')[0],
      'jam_datang_rencana': jamDatangRencana,
      'alasan': alasan,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods for status checking
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  // Helper method to get formatted time
  String get formattedTime {
    try {
      final parts = jamDatangRencana.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return jamDatangRencana;
    } catch (e) {
      return jamDatangRencana;
    }
  }

  // Helper method to get status color
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'LateArrivalRequest(id: $id, userNip: $userNip, tanggalTerlambat: $tanggalTerlambat, '
        'jamDatangRencana: $jamDatangRencana, alasan: $alasan, status: $status, '
        'approvedBy: $approvedBy, approvedAt: $approvedAt, createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }
}

class LateArrivalRequestsResponse {
  final bool success;
  final List<LateArrivalRequest> data;
  final PaginationInfo? pagination;
  final String? message;

  LateArrivalRequestsResponse({
    required this.success,
    required this.data,
    this.pagination,
    this.message,
  });

  factory LateArrivalRequestsResponse.fromJson(Map<String, dynamic> json) {
    return LateArrivalRequestsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LateArrivalRequest.fromJson(item))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
      message: json['message'],
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: _parseInt(json['currentPage'] ?? json['current_page'], defaultValue: 1),
      totalPages: _parseInt(json['totalPages'] ?? json['total_pages'], defaultValue: 1),
      totalItems: _parseInt(json['totalItems'] ?? json['total_items'], defaultValue: 0),
      itemsPerPage: _parseInt(json['itemsPerPage'] ?? json['items_per_page'], defaultValue: 10),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}

class CreateLateArrivalRequest {
  final String tanggalTerlambat;
  final String jamDatangRencana;
  final String alasan;

  CreateLateArrivalRequest({
    required this.tanggalTerlambat,
    required this.jamDatangRencana,
    required this.alasan,
  });

  Map<String, dynamic> toJson() {
    return {
      'tanggal_terlambat': tanggalTerlambat,
      'jam_datang_rencana': jamDatangRencana,
      'alasan': alasan,
    };
  }

  // Validation methods
  String? validateDate() {
    try {
      final date = DateTime.parse(tanggalTerlambat);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      if (date.isBefore(DateTime(tomorrow.year, tomorrow.month, tomorrow.day))) {
        return 'Tanggal harus minimal besok';
      }
      return null;
    } catch (e) {
      return 'Format tanggal tidak valid';
    }
  }

  String? validateTime() {
    try {
      final parts = jamDatangRencana.split(':');
      if (parts.length != 2) {
        return 'Format jam harus HH:MM';
      }
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return 'Format jam tidak valid';
      }
      
      if (hour > 10 || (hour == 10 && minute > 0)) {
        return 'Jam datang maksimal 10:00';
      }
      
      return null;
    } catch (e) {
      return 'Format jam tidak valid';
    }
  }

  String? validateReason() {
    if (alasan.trim().length < 10) {
      return 'Alasan minimal 10 karakter';
    }
    return null;
  }

  List<String> validateAll() {
    final errors = <String>[];
    
    final dateError = validateDate();
    if (dateError != null) errors.add(dateError);
    
    final timeError = validateTime();
    if (timeError != null) errors.add(timeError);
    
    final reasonError = validateReason();
    if (reasonError != null) errors.add(reasonError);
    
    return errors;
  }
}
