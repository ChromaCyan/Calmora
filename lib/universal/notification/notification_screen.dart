import 'package:armstrong/widgets/cards/notification.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/services/api.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  /// Loads user ID and fetches notifications
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

  /// Fetch user ID from storage
  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });
  }

  /// Fetch notifications using the stored user ID
  Future<void> fetchNotifications() async {
    try {
      if (_userId == null) return;

      List<Map<String, dynamic>> fetchedNotifications =
          await apiService.getNotifications(_userId!);

      setState(() {
        notifications = fetchedNotifications;
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
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) 
          : hasError
              ? const Center(child: Text("Failed to load notifications"))
              : notifications.isEmpty
                  ? const Center(child: Text("No notifications yet"))
                  : ListView.builder(
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
