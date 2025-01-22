import 'package:armstrong/config/colors.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatDetailScreen({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final List<String> _messages = []; // List to hold messages
  final TextEditingController _controller = TextEditingController();

  // Placeholder for fetching messages from a database
  void _fetchMessages() {
    // This function will later be replaced with database queries
    // For now, just simulating an empty fetch to match the current setup.
  }

  // Simulate sending a message
  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(message); // Add the new message to the list
      });
      _controller.clear(); // Clear the input field

      // Placeholder for sending the message to a database in the future
      // You can implement database saving logic here later
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Call the placeholder fetch method (will be replaced later)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName), // Display the name of the selected user
        backgroundColor: orangeContainer,
      ),
      body: Column(
        children: [
          // Chat messages display
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Align(
                    alignment: Alignment.centerRight, // All messages go to the right
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(_messages[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          // Input field for typing messages
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage, // Handle message sending
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
