// import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:armstrong/services/api.dart';
// import 'package:armstrong/services/socket_service.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:armstrong/widgets/forms/appointment_booking_form.dart';
// import 'package:armstrong/universal/chat/screen/chat_bubble.dart';
// import 'package:armstrong/universal/chat/screen/text_n_send.dart';
// import 'package:armstrong/helpers/storage_helpers.dart';
// import 'dart:ui';
// import 'package:armstrong/config/global_loader.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatId;
//   final String recipientName;
//   final String recipientId;

//   ChatScreen({
//     required this.chatId,
//     required this.recipientName,
//     required this.recipientId,
//   });

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ApiRepository _apiRepository = ApiRepository();
//   final SocketService _socketService = SocketService();
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   final ScrollController _scrollController = ScrollController();

//   List<Map<String, dynamic>> _messages = [];
//   String? _userId;
//   bool _isScrolledUp = false;
//   bool _isLoading = true;
//   bool _isSpecialist = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeUserIdAndLoadData();

//     _scrollController.addListener(() {
//       final isAtBottom = _scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 50;
//       setState(() {
//         _isScrolledUp = !isAtBottom;
//       });
//     });
//   }

//   void _initializeUserIdAndLoadData() async {
//     _userId = await StorageHelper.getUserId();
//     String? userType = await StorageHelper.getUserType();

//     if (_userId != null && userType != null) {
//       setState(() {
//         _isSpecialist = userType.toLowerCase() == 'specialist';
//       });
//     }

//     _initializeSocket();

//     _loadMessages();
//   }

//   void _initializeSocket() async {
//     final token = await _storage.read(key: 'jwt');
//     final userId = _userId;

//     if (token != null && userId != null) {
//       _socketService.registerUserRoom(userId);
//       _socketService.joinChatRoom(widget.chatId);

//       _socketService.currentChatId = widget.chatId;

//       _socketService.markChatAsRead(widget.chatId, userId);

//       _socketService.onMessageReceived = (message) {
//         final isDuplicate = _messages.any((m) =>
//             m['senderId'] == message['senderId'] &&
//             m['content'] == message['content'] &&
//             m['timestamp'] == message['timestamp']);

//         if (!isDuplicate) {
//           setState(() {
//             _messages.add(message);
//             if (widget.chatId == message['chatId']) {
//               _socketService.markMessageAsRead(widget.chatId, _userId!);
//               setState(() {
//                 final msgIndex = _messages.indexWhere(
//                   (m) => m['timestamp'] == message['timestamp'],
//                 );
//                 if (msgIndex != -1) _messages[msgIndex]['status'] = 'read';
//               });
//             }
//           });

//           if (!_isScrolledUp) {
//             Future.delayed(const Duration(milliseconds: 300), () {
//               _scrollToBottom();
//             });
//           }
//         }
//       };

//       _socketService.socket!.on('messageDelivered', (data) {
//         setState(() {
//           final msgIndex =
//               _messages.indexWhere((m) => m['timestamp'] == data['timestamp']);
//           if (msgIndex != -1) _messages[msgIndex]['status'] = 'delivered';
//         });
//       });

//       _socketService.socket!.on('messageReadUpdate', (data) {
//         setState(() {
//           final msgIndex =
//               _messages.indexWhere((m) => m['timestamp'] == data['timestamp']);
//           if (msgIndex != -1) _messages[msgIndex]['status'] = 'read';
//         });
//       });
//     }
//   }

//   void _loadMessages() async {
//     final token = await _storage.read(key: 'token');
//     if (token != null) {
//       try {
//         final fetchedMessages =
//             await _apiRepository.getChatHistory(widget.chatId, token);

//         // Format messages like before
//         final newMessages = fetchedMessages.map((message) {
//           String senderId;
//           if (message['sender'] is String) {
//             senderId = message['sender'];
//           } else if (message['sender'] is Map &&
//               message['sender']['_id'] != null) {
//             senderId = message['sender']['_id'];
//           } else {
//             senderId = 'unknown';
//           }

//           String timestamp =
//               message['timestamp'] ?? DateTime.now().toIso8601String();

//           return {
//             'senderId': senderId,
//             'content': message['content'] ?? '',
//             'timestamp': timestamp,
//             'status': message['status'] ?? 'sent',
//           };
//         }).toList();

//         final uniqueMessages = <Map<String, dynamic>>[];
//         for (var msg in newMessages) {
//           final isDuplicate = _messages.any((m) =>
//               m['senderId'] == msg['senderId'] &&
//               m['content'] == msg['content'] &&
//               m['timestamp'] == msg['timestamp']);

//           if (!isDuplicate) {
//             uniqueMessages.add(msg);
//           }
//         }

//         setState(() {
//           _messages.addAll(uniqueMessages);
//           _isLoading = false;
//         });

//         Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
//       } catch (e) {
//         print("Error loading messages: $e");
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   void _sendMessage() async {
//     final token = await _storage.read(key: 'jwt');
//     if (token != null &&
//         _controller.text.trim().isNotEmpty &&
//         _userId != null) {
//       final messageContent = _controller.text.trim();

//       final message = {
//         'senderId': _userId!,
//         'content': messageContent,
//         'timestamp': DateTime.now().toIso8601String(),
//         'status': 'sending',
//       };

//       setState(() {
//         _messages.add(message);
//         _controller.clear();
//       });

//       try {
//         //await _apiRepository.sendMessage(widget.chatId, messageContent, token);

//         _socketService.sendMessage(
//             _userId!, widget.recipientId, messageContent, widget.chatId);

//         _socketService.socket!.emit('messageDelivered', {
//           'chatId': widget.chatId,
//           'timestamp': message['timestamp'],
//         });

//         setState(() {
//           message['status'] = 'delivered';
//         });
//       } catch (e) {
//         print("Error sending message: $e");
//       }
//     }
//   }

//   void _bookAppointment(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return BlocProvider.value(
//           value: BlocProvider.of<TimeSlotBloc>(context),
//           child: AppointmentBookingForm(specialistId: widget.recipientId),
//         );
//       },
//     );
//   }

//   String _formatTimestamp(String timestamp) {
//     final dateTime = DateTime.parse(timestamp);
//     return DateFormat('hh:mm a, MMM d').format(dateTime);
//   }

//   void _scrollToBottom() {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   @override
//   void dispose() {
//     _socketService.onMessageReceived = null;
//     _socketService.onMessageDelivered = null;
//     _socketService.onMessageRead = null;
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final scheme = theme.colorScheme;

//     return WillPopScope(
//       onWillPop: () async {
//         if (_userId != null) {
//           // Leave the chat room
//           _socketService.currentChatId = null;
//           _socketService.leaveChatRoom(widget.chatId);
//           print("🚪 Left chat room ${widget.chatId}");

//           // Rejoin personal room
//           _socketService.joinPersonalRoom(_userId!);
//         }

//         Navigator.pop(context); // Go back to previous screen
//         return false; // Prevent default pop since we already handled it
//       },
//       child: Scaffold(
//         appBar: AppBar(title: Text("Chat with ${widget.recipientName}")),
//         body: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.asset("images/login_bg_image.png", fit: BoxFit.cover),
//             Container(
//               color: scheme.surface.withOpacity(0.6),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//                 child: const SizedBox.expand(),
//               ),
//             ),

//             // Main UI column remains unchanged...
//             Column(
//               children: <Widget>[
//                 if (!_isSpecialist)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ElevatedButton(
//                       onPressed: () => _bookAppointment(context),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 30),
//                         backgroundColor: scheme.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         shadowColor: Colors.black.withOpacity(0.2),
//                         elevation: 5,
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.calendar_today,
//                               color: Colors.white, size: 22),
//                           const SizedBox(width: 10),
//                           const Text(
//                             "Book Appointment Now",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 Expanded(
//                   child: _isLoading
//                       ? Center(child: GlobalLoader.loader)
//                       : _messages.isEmpty
//                           ? const Center(
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.chat_bubble_outline,
//                                       size: 50, color: Colors.grey),
//                                   SizedBox(height: 10),
//                                   Text(
//                                     "No messages yet",
//                                     style: TextStyle(
//                                         fontSize: 16, color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : ListView.builder(
//                               controller: _scrollController,
//                               itemCount: _messages.length,
//                               itemBuilder: (context, index) {
//                                 final message = _messages[index];
//                                 return ChatBubble(
//                                   content: message['content'] ?? 'No message',
//                                   timestamp:
//                                       _formatTimestamp(message['timestamp']),
//                                   status: message['status'] ?? 'sent',
//                                   isSender: message['senderId'] == _userId,
//                                   senderName: widget.recipientName,
//                                 );
//                               },
//                             ),
//                 ),
//                 TextNSend(controller: _controller, onSend: _sendMessage),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/widgets/forms/appointment_booking_form.dart';
import 'package:armstrong/universal/chat/screen/chat_bubble.dart';
import 'package:armstrong/universal/chat/screen/text_n_send.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'dart:ui';
import 'package:armstrong/config/global_loader.dart';

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
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  String? _userId;
  bool _isScrolledUp = false;
  bool _isLoading = true;
  bool _isSpecialist = false;

  @override
  void initState() {
    super.initState();
    _socketService.setActiveChat(widget.chatId);
    _initializeUserIdAndLoadData();

    _scrollController.addListener(() {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;
      setState(() {
        _isScrolledUp = !isAtBottom;
      });
    });
  }

  void _initializeUserIdAndLoadData() async {
    _userId = await StorageHelper.getUserId();
    String? userType = await StorageHelper.getUserType();

    if (_userId != null && userType != null) {
      setState(() {
        _isSpecialist = userType.toLowerCase() == 'specialist';
      });
    }

    _initializeSocket();

    _loadMessages();
  }

  void _initializeSocket() async {
    final token = await _storage.read(key: 'jwt');
    final userId = _userId;

    if (token != null && userId != null) {
      _socketService.registerUserRoom(userId);
      _socketService.joinChatRoom(widget.chatId);

      _socketService.onMessageReceived = (message) {
        final isDuplicate = _messages.any((m) =>
            m['senderId'] == message['senderId'] &&
            m['content'] == message['content'] &&
            m['timestamp'] == message['timestamp']);

        if (!isDuplicate) {
          setState(() {
            _messages.add(message);
          });

          if (!_isScrolledUp) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _scrollToBottom();
            });
          }
        }
      };
    }
  }

  void _loadMessages() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        final fetchedMessages =
            await _apiRepository.getChatHistory(widget.chatId, token);

        // Format messages like before
        final newMessages = fetchedMessages.map((message) {
          String senderId;
          if (message['sender'] is String) {
            senderId = message['sender'];
          } else if (message['sender'] is Map &&
              message['sender']['_id'] != null) {
            senderId = message['sender']['_id'];
          } else {
            senderId = 'unknown';
          }

          String timestamp =
              message['timestamp'] ?? DateTime.now().toIso8601String();

          return {
            'senderId': senderId,
            'content': message['content'] ?? '',
            'timestamp': timestamp,
            'status': message['status'] ?? 'sent',
          };
        }).toList();

        final uniqueMessages = <Map<String, dynamic>>[];
        for (var msg in newMessages) {
          final isDuplicate = _messages.any((m) =>
              m['senderId'] == msg['senderId'] &&
              m['content'] == msg['content'] &&
              m['timestamp'] == msg['timestamp']);

          if (!isDuplicate) {
            uniqueMessages.add(msg);
          }
        }

        setState(() {
          _messages.addAll(uniqueMessages);
          _isLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
      } catch (e) {
        print("Error loading messages: $e");
        setState(() => _isLoading = false);
      }
    }
  }

  void _sendMessage() async {
    final token = await _storage.read(key: 'jwt');
    if (token != null &&
        _controller.text.trim().isNotEmpty &&
        _userId != null) {
      final messageContent = _controller.text.trim();

      final message = {
        'senderId': _userId!,
        'content': messageContent,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'sent',
      };

      setState(() {
        _messages.add(message);
        _controller.clear();
      });

      try {
        //await _apiRepository.sendMessage(widget.chatId, messageContent, token);

        _socketService.sendMessage(
            _userId!, widget.recipientId, messageContent, widget.chatId);

        setState(() {
          message['status'] = 'delivered';
        });
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  void _bookAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<TimeSlotBloc>(context),
          child: AppointmentBookingForm(specialistId: widget.recipientId),
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a, MMM d').format(dateTime);
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _socketService.setActiveChat(null);
    _socketService.leaveChatRoom(widget.chatId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text("Chat with ${widget.recipientName}")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),

          /// Frosted glass overlay
          Container(
            color: scheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          /// Main Chat UI
          Column(
            children: <Widget>[
              if (!_isSpecialist)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _bookAppointment(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 30),
                      backgroundColor: scheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.2),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          "Book Appointment Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              /// Chat messages
              Expanded(
                child: _isLoading
                    ? Center(
                        child: GlobalLoader.loader,
                      )
                    : _messages.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  "No messages yet",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return ChatBubble(
                                content: message['content'] ?? 'No message',
                                timestamp:
                                    _formatTimestamp(message['timestamp']),
                                status: message['status'] ?? 'sent',
                                isSender: message['senderId'] == _userId,
                                senderName: widget.recipientName,
                              );
                            },
                          ),
              ),

              /// Input
              TextNSend(controller: _controller, onSend: _sendMessage),
            ],
          ),
        ],
      ),
    );
  }
}
