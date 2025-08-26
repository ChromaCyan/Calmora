import 'dart:convert';
import 'dart:io';
import 'package:armstrong/universal/chat/screen/ai_voice_screen.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/universal/chat/screen/chat_bubble.dart';
import 'package:armstrong/services/api.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _voiceModeEnabled = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
    _speech = stt.SpeechToText();
  }

  void _sendInitialMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addBotMessage(
        "Hi there, I'm Calmora. To help save the developers money, each response will be limited to 250-400 characters each..");
  }

  int _addBotMessage(String text, {bool isLoading = false}) {
    final msg = {
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      'isSender': false,
      'isLoading': isLoading,
    };
    setState(() {
      _messages.add(msg);
    });
    _scrollToBottom();
    return _messages.length - 1;
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
      final aiResponse =
          await _apiRepository.askGemini(content, withVoice: _voiceModeEnabled);

      final aiReply = aiResponse['reply'];
      final ttsId = aiResponse['id'];
      final ttsPending = aiResponse['ttsPending'] ?? false;

      if (_voiceModeEnabled && ttsPending && ttsId != null) {
        String? audioBase64;
        int retries = 0;

        // Poll until audio is ready (max 15 retries)
        while (audioBase64 == null && retries < 60) {
          await Future.delayed(const Duration(seconds: 1));
          audioBase64 = await _apiRepository.fetchAudio(ttsId);
          retries++;
        }

        if (audioBase64 != null) {
          final audioBytes = base64Decode(audioBase64);
          await _audioPlayer.stop();
          await _audioPlayer.play(BytesSource(audioBytes));

          // Only add message after audio is ready
          _addBotMessage(aiReply);
        } else {
          print('Audio not ready after polling.');

          _addBotMessage(aiReply);
        }
      } else {
        // No voice mode: display immediately
        _addBotMessage(aiReply);
      }
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

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Calmora AI Chatbot"),
        actions: [
          IconButton(
            icon: const Icon(Icons.graphic_eq),
            tooltip: "Voice Mode",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceChatScreen(),
                ),
              );

              // when user comes back, reset backend flag
              setState(() {
                _voiceModeEnabled = false;
              });
            },
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
