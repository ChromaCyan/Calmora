import 'package:flutter/material.dart';
import 'package:armstrong/universal/chat/screen/chat_bubble.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:armstrong/services/tts.dart';
import 'package:armstrong/services/api.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _initTTSVoice();
    _sendInitialMessage();
    _speech = stt.SpeechToText();
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

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('Speech status: $val'),
      onError: (val) => print('Speech error: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _lastWords = val.recognizedWords;
            _controller.text = _lastWords;
          });
        },
      );
    }
  }

  void _stopListeningAndSend() async {
    await _speech.stop();
    setState(() => _isListening = false);

    if (_lastWords.trim().isNotEmpty) {
      _sendMessage();
      _lastWords = '';
    }
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _speak(String text) async {
    await _ttsService.stop();
    await _ttsService.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Calmora AI Chatbot"),
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
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message or use mic...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onLongPressStart: (_) => _startListening(),
                    onLongPressEnd: (_) => _stopListeningAndSend(),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 28,
                      color: _isListening ? Colors.red : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
