class LeaveModel {
  final int id;
  final String nip;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final String? description;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveModel({
    required this.id,
    required this.nip,
    required this.startDate,
    required this.endDate,
    required this.category,
    this.description,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['tdkhadir_id'],
      nip: json['tdkhadir_nip'],
      startDate: DateTime.parse(json['tdkhadir_mulai']),
      endDate: DateTime.parse(json['tdkhadir_selesai']),
      category: json['tdkhadir_kat'],
      description: json['tdkhadir_ket'],
      status: json['status'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tdkhadir_mulai': startDate.toIso8601String(),
      'tdkhadir_selesai': endDate.toIso8601String(),
      'tdkhadir_kat': category,
      'tdkhadir_ket': description,
    };
  }
} 