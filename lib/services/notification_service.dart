import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get flutterLocalNotifications =>
      _localNotifications;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final String baseUrl = 'http://192.168.18.253:5000/api';

  Timer? _timer;

  // Initialize local notifications
  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings);

    // Request Permission for Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Show local notification with payload
  static Future<void> showNotification(
      String title, String message, Map<String, dynamic> payload) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(message, contentTitle: title),
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      message,
      platformDetails,
      payload: jsonEncode(payload), // <-- This is key for navigation
    );
  }

  Future<void> fetchAndDisplayNotifications(String userId) async {
    try {
      final token = await _storage.read(key: 'token');
      final url = Uri.parse('$baseUrl/notification/$userId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> notifications =
            List<Map<String, dynamic>>.from(json.decode(response.body));

        for (var notification in notifications) {
          String title = notification["title"] ?? "New Notification";
          String message = notification["message"] ?? "You have a new update!";

          // Pass payload as 3rd argument
          showNotification(title, message, {
            "type": notification["type"] ?? "general",
            "id": notification["id"] ?? "",
          });
        }
      } else {
        print("❌ Failed to load notifications: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching notifications: $e");
    }
  }

  // Start polling for notifications every 30 seconds
  void startPolling(String userId) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      fetchAndDisplayNotifications(userId);
    });
  }

  // Stop polling when user logs out
  void stopPolling() {
    _timer?.cancel();
  }
}
