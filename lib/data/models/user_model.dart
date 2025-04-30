class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String deviceId;
  final DateTime? createdAt;
  final String? position;
  final String? department;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.deviceId,
    this.createdAt,
    this.position,
    this.department,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      photoUrl: json['photo_url'] != null ? json['photo_url'].toString() : null,
      deviceId: json['device_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      position: json['position'],
      department: json['department'],
      phone: json['phone'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photo_url': photoUrl,
      'device_id': deviceId,
      'created_at': createdAt?.toIso8601String(),
      'position': position,
      'department': department,
      'phone': phone,
    };
  }
}