class NotificationModel {
  final int notifId;
  final String title;
  final String body;
  final String type;
  final String referenceId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notifId,
    required this.title,
    required this.body,
    required this.type,
    required this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notifId: json['notif_id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      referenceId: json['reference_id'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notif_id': notifId,
      'title': title,
      'body': body,
      'type': type,
      'reference_id': referenceId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 