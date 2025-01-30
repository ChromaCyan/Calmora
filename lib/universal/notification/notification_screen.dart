import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final List<String> notifications = [
    'You have a new appointment request.',
    'Your specialist has updated the appointment.',
    'New message from your specialist.',
    'Your appointment has been declined.',
    'Reminder: Your appointment is tomorrow.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: "Notifications",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationCard(
            notification: notifications[index],
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String notification;

  const NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          notification,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          // Handle tap (you can navigate to a detailed notification page here)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No function yet')),
          );
        },
      ),
    );
  }
}
