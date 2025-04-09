class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String deviceId;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    required this.deviceId,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0, // Default ke 0 jika null
      name: json['name'] ?? 'Unknown', // Default jika null
      email: json['email'] ?? '',
      role: json['role'] ?? 'user', // Default jika role tidak ada
      photoUrl: json['photo_url'] != null ? json['photo_url'].toString() : null, // Pastikan null tetap null
      deviceId: json['device_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null, // Gunakan tryParse agar aman
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
    };
  }
}
