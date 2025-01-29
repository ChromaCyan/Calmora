import 'package:armstrong/specialist/screens/chat/chat_screen.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/config/colors.dart';

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
        _filteredChats = _chats.where((chat) {
          final recipientName = chat['participants'][0]['firstName'] ?? '';
          return recipientName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomSearchBar(
            hintText: 'Search chats...',
            searchController: _searchController,
            onChanged: _filterChats,
            onClear: () {
              _searchController.clear();
              _filterChats('');
            },
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
                      final recipient =
                          participants.isNotEmpty ? participants[0] : {};
                      final recipientId = recipient['_id'] ?? '';
                      final recipientName = recipient['firstName'] ?? 'No Name';
                      final lastMessage = chat['lastMessage'] ?? {};
                      final messageContent =
                          lastMessage['content'] ?? 'No message';

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: orangeContainer.withOpacity(0.3),
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            recipientName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            messageContent,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
