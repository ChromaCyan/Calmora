import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SocketService {
  // Singleton setup
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // Socket and callbacks
  IO.Socket? socket;
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onNotificationReceived;

  // Local notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  Future<void> initNotifications() async {
    print("🔔 Initializing Local Notifications...");

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
  }

  /// Show local notification
  Future<void> showNotification(String senderName, String message) async {
    print("📢 Showing Notification from $senderName - $message");

    // Combine sender and message for body
    final String notificationBody = "$senderName: $message";

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Messages from your chats',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(
        notificationBody,
        contentTitle: "New Message",
      ),
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      "New Message",
      notificationBody,
      platformDetails,
    );
  }

  /// Connect to the Socket.IO server
  void connect(String token, String userId) {
    // Avoid reconnecting if already connected
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      'https://calmora-chat-real-time.onrender.com',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Connected to Socket.IO server');
      joinRoom(userId); // Join user's personal room
    });

    socket!.onDisconnect((_) => print('❌ Disconnected from server'));
    socket!.onError((error) => print('⚠️ Socket error: $error'));
    socket!.onReconnect((_) => print('🔄 Reconnecting to server...'));

    // Incoming message listener
    socket!.on('receiveMessage', (data) {
      print('📩 Received message: $data');
      onMessageReceived?.call(Map<String, dynamic>.from(data));

      final senderName = "${data["senderFirstName"]} ${data["senderLastName"]}";
      final messageContent = data["content"] ?? "You have a new message";

      showNotification(senderName, messageContent);
    });

    socket!.on('new_notification', (data) {
      final Map<String, dynamic> notification = Map<String, dynamic>.from(data);
      print("🔔 New Notification: $notification");

      // Handle based on type
      final String type = notification["type"] ?? "general";
      String title = "Notification";
      String body = notification["message"] ?? "You have a new notification";

      switch (type) {
        case "chat":
          final senderName =
              "${notification["senderFirstName"] ?? ""} ${notification["senderLastName"] ?? ""}"
                  .trim();
          title = "New Message";
          body = senderName.isNotEmpty
              ? "$senderName: ${notification["message"]}"
              : notification["message"];
          break;

        case "appointment":
          title = "Appointment Update";
          body = notification["message"] ??
              "You have a new update regarding your appointment.";
          break;

        case "article":
          title = "Article Update";
          body = notification["message"] ??
              "Your article status has been updated.";
          break;

        default:
          title = "Notification";
          body = notification["message"] ?? "You have a new notification";
          break;
      }

      // Show local notification
      showNotification(title, body);

      // Pass to app listener (if UI wants to react)
      onNotificationReceived?.call(notification);
    });
  }

  /// Send a message
  void sendMessage(
      String senderId, String recipientId, String message, String chatId) {
    if (socket == null || !socket!.connected) return;
    socket!.emit('sendMessage', {
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'chatId': chatId,
    });
  }

  /// Join a chat room
  void joinRoom(String roomId) {
    if (socket == null || !socket!.connected) return;
    socket!.emit('joinRoom', roomId);
  }

  void joinChatRoom(String chatId) {
    if (socket != null && socket!.connected) {
      socket!.emit('joinRoom', chatId);
      print("✅ Joined chat room $chatId");
    }
  }

  void registerUserRoom(String userId) {
    if (socket != null && socket!.connected) {
      socket!.emit('registerUser', userId);
      print("✅ Registered to personal room $userId for notifications");
    }
  }

  /// Disconnect from server
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
  }
}
