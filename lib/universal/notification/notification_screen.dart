import 'package:armstrong/widgets/cards/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiRepository apiService = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  bool hasError = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _loadUserId();
    if (_userId != null) {
      await fetchNotifications();
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
  }

  Future<void> fetchNotifications() async {
    try {
      if (_userId == null) return;

      List<Map<String, dynamic>> fetchedNotifications =
          await apiService.getNotifications(_userId!);

      setState(() {
        notifications =
            fetchedNotifications.where((n) => n["isRead"] == false).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: "Notifications",
        onBackPressed: () async {
          await apiService.markAllNotificationsAsRead(_userId!);
          Navigator.pop(context, 0);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load notifications"))
              : notifications.isEmpty
                  ? const Center(child: Text("No new notifications"))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(notification: notifications[index]);
                      },
                    ),
    );
  }
}
