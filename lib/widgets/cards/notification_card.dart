import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationCard({Key? key, required this.notification}) : super(key: key);

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor(notification['type']),
          child: Icon(_getIcon(notification['type']), color: Colors.white),
        ),
        title: Text(
          notification['message'],
          style: TextStyle(
            fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _formatDate(notification['createdAt']),
          style: TextStyle(color: Colors.grey),
        ),
        trailing: notification['isRead']
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
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