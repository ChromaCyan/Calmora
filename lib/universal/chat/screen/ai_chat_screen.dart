import 'package:flutter/material.dart';
import 'package:armstrong/universal/chat/screen/chat_bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:armstrong/services/tts.dart';
import 'package:armstrong/services/api.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TTSService _ttsService = TTSService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initTTSVoice();
    _sendInitialMessage();
  }

  void _initTTSVoice() async {
    await _ttsService.initTTS();
  }

  void _sendInitialMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addBotMessage("Hi there, I'm Calmora. How are you feeling today?");
  }

  void _addBotMessage(String text) {
    final msg = {
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      'isSender': false,
    };
    setState(() {
      _messages.add(msg);
    });
    _scrollToBottom();
    _speak(text);
  }

  void _addUserMessage(String text) {
    final msg = {
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      'isSender': true,
    };
    setState(() {
      _messages.add(msg);
      _controller.clear();
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    _addUserMessage(content);

    try {
      final aiReply = await _apiRepository.askGemini(content);
      _addBotMessage(aiReply);
    } catch (e) {
      _addBotMessage("Oops! Something went wrong. Please try again later.");
      print("Gemini error: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _speak(String text) async {
    await _ttsService.stop();
    await _ttsService.speak(text);
  }

  void _readLatestBotMessage() {
    final latestBotMessage = _messages.lastWhere(
      (msg) => msg['isSender'] == false,
      orElse: () => {},
    );

    if (latestBotMessage.isNotEmpty) {
      final content = latestBotMessage['content'] as String;
      _speak(content);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No message from Calmora yet.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calmora (AI Chatbot)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: _readLatestBotMessage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return GestureDetector(
                  onTap: () => _speak(msg['content']),
                  child: ChatBubble(
                    content: msg['content'],
                    timestamp: _formatTimestamp(msg['timestamp']),
                    status: 'sent',
                    isSender: msg['isSender'],
                    senderName: msg['isSender'] ? 'You' : 'Calmora',
                  ),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
