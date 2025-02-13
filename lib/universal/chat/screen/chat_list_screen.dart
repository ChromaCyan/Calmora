import 'package:flutter/material.dart';
import 'package:armstrong/universal/chat/screen/chat_screen.dart';
import 'package:armstrong/widgets/navigation/search.dart';
import 'package:armstrong/services/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/universal/chat/screen/chat_card.dart'; // Import ChatCard

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
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        final chats = await _apiRepository.getChatList(token);
        setState(() {
          _chats = chats;
          _filteredChats = chats;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Failed to load chats. Please try again.";
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "User not authenticated.";
        _isLoading = false;
      });
    }
  }

  void _filterChats(String query) {
    setState(() {
      _filteredChats = query.isEmpty
          ? List.from(_chats)
          : _chats.where((chat) {
              final recipientName = chat['participants']?.isNotEmpty ?? false
                  ? chat['participants'][0]['firstName'] ?? ''
                  : '';
              return recipientName.toLowerCase().contains(query.toLowerCase());
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          const SizedBox(height: 20),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          _errorMessage,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    : _filteredChats.isEmpty
                        ? Center(
                            child: Text(
                              'No chats found.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                color: theme.colorScheme.onBackground.withOpacity(0.6),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredChats.length,
                            itemBuilder: (context, index) {
                              final chat = _filteredChats[index];

                              final participants = chat['participants'] ?? [];
                              final chatId = chat['chatId'] ?? '';
                              final recipient = participants.isNotEmpty ? participants[0] : {};
                              final recipientId = recipient['_id'] ?? '';
                              final recipientName = recipient['firstName'] ?? 'No Name';
                              final lastMessage = chat['lastMessage'] ?? {};
                              final messageContent = lastMessage['content'] ?? 'No message';

                              return ChatCard(
                                chatId: chatId,
                                recipientId: recipientId,
                                recipientName: recipientName,
                                lastMessage: messageContent,
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
