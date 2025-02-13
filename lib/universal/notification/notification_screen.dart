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
  String selectedCategory = 'unread'; // Default to unread

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    _userId = await _storage.read(key: 'userId');
    if (_userId != null) {
      await fetchNotifications();
    } else {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

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
    final theme = Theme.of(context);
    final unreadNotifications = notifications.where((n) => !n["isRead"]).toList();
    final readNotifications = notifications.where((n) => n["isRead"]).toList();

    List<Map<String, dynamic>> displayedNotifications =
        selectedCategory == 'unread' ? unreadNotifications : readNotifications;

    return Scaffold(
      appBar: UniversalAppBar(
        title: "Notifications",
        onBackPressed: () => Navigator.pop(context, 0),
      ),
      body: Column(
        children: [
          const SizedBox(height:20),
          _buildCategorySelector(),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? Center(
                        child: Text(
                          "Failed to load notifications",
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error),
                        ),
                      )
                    : displayedNotifications.isEmpty
                        ? Center(
                            child: Text(
                              "No ${selectedCategory == 'unread' ? 'unread' : 'read'} notifications",
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayedNotifications.length,
                            itemBuilder: (context, index) {
                              return NotificationCard(notification: displayedNotifications[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  /// Category Selector for Unread/Read Notifications
  Widget _buildCategorySelector() {
    return Row(
      children: [
        _buildCategoryButton('unread', 'Unread'),
        _buildCategoryButton('read', 'Read'),
      ],
    );
  }

  /// Single category button with full-width style
  Widget _buildCategoryButton(String category, String label) {
    final isSelected = selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}