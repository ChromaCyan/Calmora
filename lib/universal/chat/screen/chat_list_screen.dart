import 'package:armstrong/specialist/screens/chat/chat_screen.dart';
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
  List<Map<String, dynamic>> _filteredChats = [];
  final TextEditingController _searchController = TextEditingController();

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
          _filteredChats = chats; 
        });
      } catch (e) {
        print("Error loading chats: $e");
      }
    }
  }

  // Method to filter chats based on search input
  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredChats = List.from(_chats); 
      });
    } else {
      setState(() {
        _filteredChats = _chats
            .where((chat) {
              final recipientName = chat['participants'][0]['firstName'] ?? '';
              return recipientName.toLowerCase().contains(query.toLowerCase());
            })
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: _filterChats, 
            ),
          ),
          Expanded(
            child: _filteredChats.isEmpty
                ? const Center(
                    child: Text(
                      'No chats found.',
                      style: TextStyle(fontSize: 18.0, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = _filteredChats[index];

                      // Add null checks for all required properties
                      final participants = chat['participants'] ?? [];
                      final chatId = chat['chatId'] ?? '';
                      final recipient = participants.isNotEmpty ? participants[0] : {};
                      final recipientId = recipient['_id'] ?? '';
                      final recipientName = recipient['firstName'] ?? 'No Name';
                      final lastMessage = chat['lastMessage'] ?? {};
                      final messageContent = lastMessage['content'] ?? 'No message';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(recipientName),
                        subtitle: Text(messageContent),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                chatId: chatId,
                                recipientId: recipientId,
                                recipientName: recipientName, 
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
