import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/widgets/forms/appointment_booking_form.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientName;
  final String recipientId;

  ChatScreen({
    required this.chatId,
    required this.recipientName,
    required this.recipientId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();
  final SocketService _socketService = SocketService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> _messages = [];
  String _messageContent = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserIdAndLoadData();
  }

  void _initializeUserIdAndLoadData() async {
    _userId = await _storage.read(key: 'userId');
    if (_userId != null) {
      setState(() {});
    }

    _initializeSocket();
    _loadMessages();
  }

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


  void _loadMessages() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        final messages =
            await _apiRepository.getChatHistory(widget.chatId, token);
        setState(() {
          _messages = messages.map((message) {
            return {
              'senderId': message['sender']['_id'],
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

  void _sendMessage() async {
    final token = await _storage.read(key: 'token');
    if (token != null && _controller.text.trim().isNotEmpty) {
      final messageContent = _controller.text.trim();

      await _apiRepository.sendMessage(widget.chatId, messageContent, token);
      _socketService.sendMessage(
          token, widget.recipientId, messageContent, widget.chatId);

      setState(() {
        _messages.add({
          'senderId': _userId,
          'content': messageContent,
          'timestamp': DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a, MMM d').format(dateTime);
  }

  void _bookAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<AppointmentBloc>(context),
          child: AppointmentBookingForm(specialistId: widget.recipientId),
        );
      },
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context).colorScheme;

  return Scaffold(
    appBar: UniversalAppBar(
      title: "Chat with ${widget.recipientName}",
      onBackPressed: () => Navigator.pop(context),
    ),
    body: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _bookAppointment(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              backgroundColor: theme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black.withOpacity(0.2),
              elevation: 5,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Text(
                  "Create Appointment Now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isSender = message['senderId'] == _userId;
              final content = message['content'] ?? 'No message';
              final timestamp = message['timestamp'] ?? DateTime.now().toString();

              return Align(
                alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isSender ? theme.primary.withOpacity(0.2) : theme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isSender ? const Radius.circular(12) : Radius.zero,
                      bottomRight: isSender ? Radius.zero : const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isSender)
                        Text(
                          widget.recipientName,
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.onSurface),
                        ),
                      Text(content, style: TextStyle(color: theme.onBackground)),
                      const SizedBox(height: 5),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(fontSize: 10, color: theme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
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
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: theme.primary),
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