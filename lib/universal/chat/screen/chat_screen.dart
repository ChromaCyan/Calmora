import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chat_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientId;

  ChatScreen({required this.chatId, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  final SocketService _socketService = SocketService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> _messages = [];
  String _messageContent = '';

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _loadMessages();
  }

  // Connect to Socket.IO
  void _initializeSocket() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      _socketService.connect(token);  
      _socketService.onMessageReceived = (message) {
        setState(() {
          _messages.add(message);
        });
      };
    }
  }

  // Load chat history from the API
  void _loadMessages() async {
  final token = await _storage.read(key: 'token');
  if (token != null) {
    try {
      final messages = await _apiRepository.getChatHistory(widget.chatId, token);
      setState(() {
        _messages = messages.map((message) {
          // Ensure that the sender details are correctly mapped
          return {
            'senderId': message['sender']['_id'],
            'firstName': message['sender']['firstName'],
            'lastName': message['sender']['lastName'],
            'content': message['content'],
            'timestamp': message['timestamp'],
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading messages: $e");
    }
  }
}

  // Send message via API and Socket.IO
  void _sendMessage() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      await _apiRepository.sendMessage(widget.chatId, _messageContent, token);

      // Send message via socket
      _socketService.sendMessage(token, widget.recipientId, _messageContent, widget.chatId);

      setState(() {
        _messages.add({
          'senderId': token,
          'firstName': 'Your', // Replace this with your actual first name if available
          'lastName': 'Name', // Replace this with your actual last name if available
          'content': _messageContent,
          'timestamp': DateTime.now().toString(),
        });
        _messageContent = ''; 
      });
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientId}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text('${message['firstName']} ${message['lastName']}: ${message['content']}'),
                  subtitle: Text(message['timestamp']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _messageContent = value;
                      });
                    },
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
