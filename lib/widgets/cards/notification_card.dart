import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onMarkAsRead,
    this.onTap,
  }) : super(key: key);

  IconData _getIcon(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble;
      case 'appointment':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'chat':
        return Colors.blue;
      case 'appointment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification['isRead'] == true;

    return InkWell(
      onTap: onTap, // 👈 make entire card tappable
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: _getColor(notification['type']),
            child: Icon(_getIcon(notification['type']), color: Colors.white),
          ),
          title: Text(
            notification['message'],
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            _formatDate(notification['createdAt']),
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: isRead
              ? null
              : IconButton(
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.greenAccent),
                  onPressed: onMarkAsRead,
                ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date).toLocal();
    return "${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')} - ${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
  }
}
