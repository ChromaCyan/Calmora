import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // Load chats for both users
  void _loadChats() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        final chats = await _apiRepository.getChatList(token);
        setState(() {
          _chats = chats;
        });
      } catch (e) {
        print("Error loading chats: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];

          // Add null checks for all required properties
          final participants = chat['participants'] ?? [];
          final chatId = chat['chatId'] ?? '';
          final firstName =
              (participants.isNotEmpty && participants[0]['firstName'] != null)
                  ? participants[0]['firstName']
                  : 'No Name';
          final lastMessage = chat['lastMessage'] ?? {};
          final messageContent = lastMessage['content'] ?? 'No message';

          return ListTile(
            title: Text(firstName),
            subtitle: Text(messageContent),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chat['chatId'], 
                    recipientId: chat['participants'][0]['_id'], 
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
