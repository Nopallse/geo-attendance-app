class Attendance {
  final int id;
  final DateTime? tanggal;
  final DateTime? jamMasuk;
  final DateTime? jamKeluar;
  final String? status;
  final String? statusMasuk;
  final String? statusKeluar;
  final Map<String, dynamic>? user;

  Attendance({
    required this.id,
    this.tanggal,
    this.jamMasuk,
    this.jamKeluar,
    this.status,
    this.statusMasuk,
    this.statusKeluar,
    this.user,
  });

  // Getter untuk kompatibilitas kode lama
  DateTime? get checkInTime => jamMasuk;
  DateTime? get checkOutTime => jamKeluar;
  String? get checkInStatus => statusMasuk;
  String? get checkOutStatus => statusKeluar;

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      tanggal: json['tanggal'] != null ? DateTime.tryParse(json['tanggal']) : null,
      jamMasuk: json['jam_masuk'] != null ? DateTime.tryParse(json['jam_masuk']) : null,
      jamKeluar: json['jam_keluar'] != null ? DateTime.tryParse(json['jam_keluar']) : null,
      status: json['status'] as String?,
      statusMasuk: json['status_masuk'] as String?,
      statusKeluar: json['status_keluar'] as String?,
      user: json['user'] is Map<String, dynamic> ? json['user'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal?.toIso8601String(),
      'jam_masuk': jamMasuk?.toIso8601String(),
      'jam_keluar': jamKeluar?.toIso8601String(),
      'status': status,
      'status_masuk': statusMasuk,
      'status_keluar': statusKeluar,
      'user': user,
    };
  }

  @override
  String toString() {
    return 'Attendance(id: $id, tanggal: $tanggal, jamMasuk: $jamMasuk, jamKeluar: $jamKeluar, '
        'status: $status, statusMasuk: $statusMasuk, statusKeluar: $statusKeluar, user: $user)';
  }
}
