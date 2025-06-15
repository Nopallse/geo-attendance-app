class User {
  final int id;
  final String username;
  final String email;
  final String level;
  final int? idOpd;
  final int? idUpt;
  final int status;
  final String deviceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.level,
    this.idOpd,
    this.idUpt,
    required this.status,
    required this.deviceId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? '',
      level: json['level'] ?? '0',
      idOpd: json['id_opd'],
      idUpt: json['id_upt'],
      status: json['status'] ?? 0,
      deviceId: json['device_id'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'level': level,
      'id_opd': idOpd,
      'id_upt': idUpt,
      'status': status,
      'device_id': deviceId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, level: $level, '
        'idOpd: $idOpd, idUpt: $idUpt, status: $status, deviceId: $deviceId, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
