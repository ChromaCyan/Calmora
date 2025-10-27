import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';
import 'package:armstrong/services/notification_service.dart';

class SocketService {
  // Singleton setup
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // Socket and callbacks
  IO.Socket? socket;
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(Map<String, dynamic>)? onNotificationReceived;
  GlobalKey<NavigatorState>? navigatorKey;

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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && navigatorKey != null) {
          final payloadMap =
              Map<String, dynamic>.from(jsonDecode(response.payload!));
          final type = payloadMap["type"];

          switch (type) {
            case "chat":
              navigatorKey!.currentState!.push(MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: payloadMap["chatId"],
                  recipientId: payloadMap["senderId"],
                  recipientName:
                      "${payloadMap["senderFirstName"]} ${payloadMap["senderLastName"]}",
                ),
              ));
              break;

            case "appointment":
              final userRole = payloadMap["role"];
              if (userRole == "Patient") {
                navigatorKey!.currentState!.push(MaterialPageRoute(
                  builder: (_) => PatientHomeScreen(initialTabIndex: 3),
                ));
              } else if (userRole == "Specialist") {
                navigatorKey!.currentState!.push(MaterialPageRoute(
                  builder: (_) => SpecialistHomeScreen(initialTabIndex: 4),
                ));
              }
              break;

            case "article":
              navigatorKey!.currentState!.push(MaterialPageRoute(
                builder: (_) => SpecialistHomeScreen(initialTabIndex: 1),
              ));
              break;

            default:
              break;
          }
        }
      },
    );
  }

  /// Show local notification
  Future<void> showNotification(
      String title, String body, Map<String, dynamic> payload) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: 'Messages from your chats',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // ⚡ Pass payload as JSON string
    await NotificationService.flutterLocalNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformDetails,
      payload: jsonEncode(payload), 
    );
  }

  String? _activeChatId;

  void setActiveChat(String? chatId) {
    _activeChatId = chatId;
    print("🟩 Active chat set to: $_activeChatId");
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

      final chatId = data["chatId"];
      final senderName =
          "${data["senderFirstName"] ?? ""} ${data["senderLastName"] ?? ""}"
              .trim();
      final messageContent = data["content"] ?? "You have a new message";

      // 🧠 Only show system notification if the message is for a different chat
      if (_activeChatId == null || _activeChatId != chatId) {
        if (_activeChatId == null || _activeChatId != chatId) {
          showNotification(senderName, messageContent, {
            "type": "chat",
            "chatId": chatId,
            "senderId": data["senderId"],
            "senderFirstName": data["senderFirstName"],
            "senderLastName": data["senderLastName"],
          });
        }
      } else {
        print(
            "💬 Message belongs to active chat ($_activeChatId), skipping system notification.");
      }
    });

    socket!.on('new_notification', (data) {
      final Map<String, dynamic> notification = Map<String, dynamic>.from(data);

      String type = notification["type"] ?? "general";
      String title = "Notification";
      String body = notification["message"] ?? "You have a new notification";

      switch (type) {
        case "chat":
          title = "New Message";
          body =
              "${notification["senderFirstName"]} ${notification["senderLastName"]}: ${notification["message"]}";
          break;
        case "appointment":
          title = "Appointment Update";
          break;
        case "article":
          title = "Article Update";
          break;
      }

      NotificationService.showNotification(title, body);
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

  void leaveChatRoom(String chatId) {
    if (socket != null && socket!.connected) {
      socket!.emit('leaveRoom', chatId);
      print("🚪 Left chat room $chatId");
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
