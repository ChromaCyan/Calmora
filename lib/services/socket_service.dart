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

    await _localNotifications.initialize(settings);
  }

  /// Show local notification
  Future<void> showNotification(String title, String message) async {
    print("📢 Showing Notification: $title - $message");
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(0, title, message, platformDetails);
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
      showNotification("New Message", data["message"] ?? "You have a new message");
    });

    // Incoming notification listener
    socket!.on('new_notification', (data) {
      print('🔔 New notification: $data');
      onNotificationReceived?.call(Map<String, dynamic>.from(data));
      if (data["message"] != null) {
        showNotification("New Notification", data["message"]);
      }
    });
  }

  /// Send a message
  void sendMessage(String senderId, String recipientId, String message, String chatId) {
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

  /// Disconnect from server
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
  }
}
