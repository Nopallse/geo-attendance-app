import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../styles/colors.dart';
import '../../styles/typography.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  Color _getNotificationColor() {
    if (notification.isRead) {
      return Colors.grey;
    }

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
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.grey.shade200 : color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : color.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.subtitle2.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                              color: notification.isRead ? Colors.grey[600] : Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTypography.bodyText2.copyWith(
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(notification.createdAt, locale: 'id'),
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}