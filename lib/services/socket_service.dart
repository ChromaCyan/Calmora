import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Callback functions for receiving messages and notifications
  Function? onMessageReceived;
  Function? onNotificationReceived;

  // Initialize connection to Socket.IO server
  void connect(String userId) {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': userId},
    });

    socket.on('connect', (_) {
      print('Connected to Socket.IO server');
    });

    // Listen for new messages
    socket.on('receiveMessage', (data) {
      print('Received message: $data');
      if (onMessageReceived != null) {
        onMessageReceived!(data);
      }
    });

    // Listen for new notifications
    socket.on('new_notification', (data) {
      print('New notification: $data');
      if (onNotificationReceived != null) {
        onNotificationReceived!(data);
      }
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  // Emit message to the server
  void sendMessage(String senderId, String recipientId, String message, String chatId) {
    socket.emit('sendMessage', {
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'chatId': chatId,
    });
  }

  // Join a specific chat room
  void joinRoom(String roomId) {
    socket.emit('joinRoom', roomId);
  }

  // Disconnect from the Socket.IO server
  void disconnect() {
    socket.disconnect();
  }
}
