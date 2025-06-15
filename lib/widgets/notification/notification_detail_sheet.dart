import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationDetailSheet extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailSheet({
    Key? key,
    required this.notification,
  }) : super(key: key);

  Color _getNotificationColor() {
    switch (notification.type.toLowerCase()) {
      case 'attendance':
        return const Color(0xFF2196F3);
      case 'leave':
        return const Color(0xFFFF9800);
      case 'office':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNotificationColor();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.headline6.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.body,
                    style: AppTypography.bodyText1.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(notification.createdAt, locale: 'id'),
                      style: AppTypography.bodyText2.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    if (notification.referenceId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: ${notification.referenceId}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}