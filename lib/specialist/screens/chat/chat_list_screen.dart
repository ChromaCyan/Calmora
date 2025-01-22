import 'package:armstrong/config/colors.dart';
import 'package:armstrong/specialist/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // List of the Contacts
  final List<Map<String, String>> chatList = [
    {'id': '1', 'name': 'Juan Joe Cruz', 'lastMessage': 'Hey, how are you?'},
    {'id': '2', 'name': 'Hapeh men', 'lastMessage': 'Let’s meet tomorrow!'},
    {'id': '3', 'name': 'John Doe', 'lastMessage': 'See you later.'},
    {'id': '4', 'name': 'Jane Smith', 'lastMessage': 'Good morning!'},
  ];

  // This list will store the filtered search results
  List<Map<String, String>> filteredChatList = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially, show all chats
    filteredChatList = List.from(chatList); // Default state (all chats visible)
  }

  // Method to handle search input and filter chat list
  void _filterChats(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredChatList = List.from(chatList); // Reset to show all chats
      });
    } else {
      setState(() {
        filteredChatList = chatList
            .where((chat) => chat['name']!
                .toLowerCase()
                .contains(query.toLowerCase())) 
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: orangeContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle additional options
            },
          ),
        ],
      ),
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
              onChanged: _filterChats, // Call _filterChats whenever the input changes
            ),
          ),
          // Display Chat History label
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Chat History',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: orangeContainer,
              ),
            ),
          ),
          // Chat list after filtering (filtered results based on search query)
          Expanded(
            child: _searchController.text.isEmpty
                ? ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      final chat = chatList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.black),
                        ),
                        title: Text(chat['name']!),
                        subtitle: Text(chat['lastMessage']!),
                        onTap: () {
                          // Navigate to ChatDetailScreen with user data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                userId: chat['id']!,
                                userName: chat['name']!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : filteredChatList.isEmpty
                    ? const Center(
                        child: Text(
                          'No chats found.',
                          style: TextStyle(fontSize: 18.0, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredChatList.length,
                        itemBuilder: (context, index) {
                          final chat = filteredChatList[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              child: const Icon(Icons.person, color: Colors.black),
                            ),
                            title: Text(chat['name']!),
                            subtitle: Text(chat['lastMessage']!),
                            onTap: () {
                              // Navigate to ChatDetailScreen with user data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    userId: chat['id']!,
                                    userName: chat['name']!,
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