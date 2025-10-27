import 'package:armstrong/widgets/cards/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';
import 'package:armstrong/config/global_loader.dart';
import 'package:armstrong/config/global_error.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final void Function(int unreadCount)? onUnreadCountChanged;
  NotificationsScreen({this.onUnreadCountChanged});

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
  String selectedCategory = 'unread';
  String? _role;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _storage.read(key: 'userType');
    setState(() => _role = role);
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

  Future<void> _markAllAsReadAndExit() async {
    if (_userId != null) {
      await apiService.markAllNotificationsAsRead(_userId!);
      setState(() {
        for (var notification in notifications) {
          notification["isRead"] = true;
        }
      });

      if (widget.onUnreadCountChanged != null) {
        widget.onUnreadCountChanged!(0); // all read
      }
    }

    Navigator.pop(context, 0); // optional
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadNotifications =
        notifications.where((n) => !n["isRead"]).toList();
    final readNotifications = notifications.where((n) => n["isRead"]).toList();

    List<Map<String, dynamic>> displayedNotifications =
        selectedCategory == 'unread' ? unreadNotifications : readNotifications;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () {
            final unreadCount = notifications.where((n) => !n["isRead"]).length;
            Navigator.pop(context); 
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Colors.greenAccent),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsReadAndExit, // 👈 manual trigger
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),

          // Frosted glass blur
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          // Main content
          Column(
            children: [
              const SizedBox(height: 10),
              _buildCategorySelector(theme),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? Center(
                        child: GlobalLoader.loader,
                      )
                    : hasError
                        ? GlobalErrorWidget(
                            onRetry: () async {
                              await fetchNotifications();
                            },
                            message: "Failed to load notifications",
                          )
                        : displayedNotifications.isEmpty
                            ? Center(
                                child: Text(
                                  "No ${selectedCategory == 'unread' ? 'unread' : 'read'} notifications",
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  await fetchNotifications();
                                },
                                child: ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: displayedNotifications.length,
                                    itemBuilder: (context, index) {
                                      final notif =
                                          displayedNotifications[index];

                                      return NotificationCard(
                                        notification: notif,
                                        onMarkAsRead: () async {
                                          try {
                                            await apiService
                                                .markNotificationAsRead(
                                                    notif["_id"]);
                                            setState(
                                                () => notif["isRead"] = true);

                                            // Immediately update unread badge
                                            final unreadCount = notifications
                                                .where((n) => !n["isRead"])
                                                .length;
                                            if (widget.onUnreadCountChanged !=
                                                null) {
                                              widget.onUnreadCountChanged!(
                                                  unreadCount);
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Failed to mark as read")),
                                            );
                                          }
                                        },
                                        onTap: () async {
                                          // Mark as read if unread
                                          if (notif["isRead"] == false) {
                                            await apiService
                                                .markNotificationAsRead(
                                                    notif["_id"]);
                                            setState(
                                                () => notif["isRead"] = true);
                                          }

                                          if (notif["type"] == "chat") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  chatId: notif["chatId"],
                                                  recipientId:
                                                      notif["senderId"],
                                                  recipientName:
                                                      "${notif["senderFirstName"]} ${notif["senderLastName"]}",
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          int? tabIndex;

                                          if (_role == "Patient") {
                                            if (notif["type"] ==
                                                "appointment") {
                                              tabIndex = 3; // Appointments
                                            } else {
                                              tabIndex = null;
                                            }
                                          } else if (_role == "Specialist") {
                                            if (notif["type"] == "article") {
                                              tabIndex = 1;
                                            } else if (notif["type"] ==
                                                "appointment") {
                                              tabIndex =
                                                  4; // Appointments for specialist
                                            }
                                          }

                                          if (tabIndex != null) {
                                            Navigator.pop(context,
                                                tabIndex); // Return tab index
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                      );
                                    })),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// Category Selector for Unread/Read Notifications
  Widget _buildCategorySelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildCategoryButton('unread', 'Unread', theme),
          _buildCategoryButton('read', 'Read', theme),
        ],
      ),
    );
  }

  /// Single category button with full-width style
  Widget _buildCategoryButton(String category, String label, ThemeData theme) {
    final isSelected = selectedCategory == category;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCategory = category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
