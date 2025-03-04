import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket; // Make nullable to avoid late initialization errors

  Function? onMessageReceived;
  Function? onNotificationReceived;

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
  void connect(String token) {
    if (socket != null && socket!.connected) return;

    socket = IO.io(
        'https://armstrong-api.vercel.app/api',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build());

    socket!.connect();

    socket!.onConnect((_) {
      print('✅ Connected to Socket.IO server');
    });

    socket!.onDisconnect((_) {
      print('❌ Disconnected from server');
    });

    socket!.onError((error) {
      print('⚠️ Socket error: $error');
    });

    socket!.onReconnect((_) {
      print('🔄 Reconnecting to server...');
    });

    /// Listen for incoming messages
    socket!.on('receiveMessage', (data) {
      print('📩 Received message: $data');
      onMessageReceived?.call(data);
      showNotification(
          "New Message", data["message"] ?? "You have a new message");
    });

    /// Listen for new notifications
    socket!.on('new_notification', (data) {
      print('🔔 New notification: $data');
      onNotificationReceived?.call(data);

      // Ensuring messages exist
      if (data["message"] == null) {
        print("❌ Error: 'message' field is missing in notification payload!");
        return; 
      }

      showNotification(
          "New Message", data["message"] ?? "You have a new message");
    });
  }

  /// Emit a message to the server
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

  /// Join a specific chat room
  void joinRoom(String roomId) {
    if (socket == null || !socket!.connected) return;
    socket!.emit('joinRoom', roomId);
  }

  /// Disconnect from the server
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
  }
}
