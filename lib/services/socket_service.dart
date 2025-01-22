import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  // Initialize connection to Socket.IO server
  void connect(String userId) {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': userId},
    });

    socket.on('connect', (_) {
      print('Connected to Socket.IO server');
    });

    socket.on('receiveMessage', (data) {
      print('Received message: $data');
      // Handle the received message, e.g., call a callback function
      if (onMessageReceived != null) {
        onMessageReceived!(data);
      }
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  // Callback function for message reception
  Function? onMessageReceived;

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
