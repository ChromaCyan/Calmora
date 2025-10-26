import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();
  String? currentChatId;

  IO.Socket? socket;

  // callbacks
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onNotificationReceived;
  Function(Map<String, dynamic>)? onMessageDelivered;
  Function(Map<String, dynamic>)? onMessageRead;

  // Local notifications
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  Future<void> initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
  }

  /// Show local notification
  Future<void> showNotification(String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Messages from your chats',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  /// Connect to the Socket.IO server
  void connect(String token, String userId) {
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
      registerUserRoom(userId);
    });

    socket!.onDisconnect((_) => print('❌ Disconnected from server'));
    socket!.onError((error) => print('⚠️ Socket error: $error'));
    socket!.onReconnect((_) => print('🔄 Reconnecting to server...'));

    // 🔹 Receive message
    socket!.on('receiveMessage', (data) {
      final message = Map<String, dynamic>.from(data);
      print('📩 Received message: $message');
      onMessageReceived?.call(message);
    });

    // 🔹 Message delivered acknowledgment
    socket!.on('messageDelivered', (data) {
      final deliveredData = Map<String, dynamic>.from(data);
      print('📬 Message delivered: $deliveredData');
      onMessageDelivered?.call(deliveredData);
    });

    // 🔹 Message read update
    socket!.on('messageReadUpdate', (data) {
      final readData = Map<String, dynamic>.from(data);
      print('👀 Message read update: $readData');
      onMessageRead?.call(readData);
    });

    // 🔹 New notification (only triggered if recipient not in chat)
    socket!.on('new_notification', (data) {
      final notification = Map<String, dynamic>.from(data);
      print("🔔 New Notification: $notification");

      if (notification['chatId'] == currentChatId) {
        print("💬 Skipping notification — already in chat ${currentChatId}");
        return;
      }

      final type = notification["type"] ?? "general";
      String title = "Notification";
      String body = notification["message"] ?? "You have a new message";

      if (type == "chat") {
        final senderName =
            "${notification["senderFirstName"] ?? ""} ${notification["senderLastName"] ?? ""}"
                .trim();
        title = "New Message";
        body = senderName.isNotEmpty
            ? "$senderName: ${notification["message"]}"
            : notification["message"];
      }

      showNotification(title, body);
      onNotificationReceived?.call(notification);
    });
  }

  /// Send message (status: sending → delivered handled via callbacks)
  void sendMessage(
      String senderId, String recipientId, String message, String chatId) {
    if (socket == null || !socket!.connected) return;

    print("📤 Sending message: $message");
    socket!.emit('sendMessage', {
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'chatId': chatId,
    });
  }

  /// Emit read receipt
  void markMessageAsRead(String chatId, String readerId) {
    if (socket == null || !socket!.connected) return;
    print("👀 Emitting messageRead for chat: $chatId by $readerId");
    socket!.emit('messageRead', {
      'chatId': chatId,
      'readerId': readerId,
    });
  }

  /// Join chat room
  void joinChatRoom(String chatId) {
    if (socket != null && socket!.connected) {
      socket!.emit('joinRoom', chatId);
      print("✅ Joined chat room $chatId");
    }
  }

  void joinPersonalRoom(String userId) {
    if (socket != null && socket!.connected) {
      socket!.emit('registerUser', userId);
      print("👤 Rejoined personal room: $userId");
    }
  }

  /// Register user for personal notifications
  void registerUserRoom(String userId) {
    if (socket != null && socket!.connected) {
      socket!.emit('registerUser', userId);
      print("✅ Registered to personal room $userId");
    }
  }

  void leaveChatRoom(String chatId) {
    if (socket != null && socket!.connected) {
      socket!.emit('leaveRoom', chatId);
      print("🚪 Left chat room $chatId");
    }
  }

  void markChatAsRead(String chatId, String userId) {
    if (socket != null && socket!.connected) {
      print("👀 Marking chat $chatId as read by $userId");
      socket!.emit('messageRead', {'chatId': chatId, 'readerId': userId});
    }
  }

  /// Disconnect
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
    }
  }
}
