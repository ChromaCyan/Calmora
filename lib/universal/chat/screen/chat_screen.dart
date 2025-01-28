import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/patient/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/patient/blocs/appointment/appointment_event.dart';
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
    return Scaffold(
      appBar: UniversalAppBar(
        title: "Chat with ${widget.recipientName}",
        onBackPressed: () {
          Navigator.pop(context);
        },
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _bookAppointment(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSender = message['senderId'] == _userId;

                return Align(
                  alignment:
                      isSender ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color:
                          isSender ? Colors.green.shade100 : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft:
                            isSender ? Radius.circular(12) : Radius.zero,
                        bottomRight:
                            isSender ? Radius.zero : Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSender)
                          Text(
                            widget.recipientName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        Text(
                          message['content'],
                          style: TextStyle(
                            color: isSender ? Colors.black87 : Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSender ? Colors.black54 : Colors.grey,
                          ),
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
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
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