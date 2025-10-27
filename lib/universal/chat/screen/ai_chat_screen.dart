import 'dart:convert';
import 'dart:io';
import 'package:armstrong/universal/chat/screen/ai_voice_screen.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/universal/chat/screen/chat_bubble.dart';
import 'package:armstrong/services/gemini_api.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:armstrong/widgets/chat/typing_indicator.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final ApiRepository2 _apiRepository = ApiRepository2();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _voiceModeEnabled = false;

  String? _chatId;
  String? _userId;
  bool _isLoading = true;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';
  String _collectedSpeech = '';

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _userId = await StorageHelper.getUserId();

    if (_userId == null) {
      print("⚠️ No user ID found in storage!");
      return;
    }

    try {
      final chatData = await _apiRepository.getChatHistory(_userId!);

      if (chatData != null) {
        setState(() {
          _chatId = chatData['chatId'];
          _messages.addAll(List<Map<String, dynamic>>.from(chatData['messages'])
              .map((msg) => {
                    'content': msg['content'],
                    'timestamp': msg['timestamp'],
                    'isSender': msg['sender'] == 'user',
                  }));
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        _sendInitialMessage();
      }
    } catch (e) {
      print("Error loading AI chat: $e");
      _sendInitialMessage();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendInitialMessage() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    _addBotMessage(
      "Hi there, I'm Calmora — your emotional support companion here in the app.",
    );

    await Future.delayed(const Duration(milliseconds: 2000));

    _addBotMessage(
      "I'm here to listen and help you process your thoughts and feelings whenever you need someone to talk to.",
    );

    await Future.delayed(const Duration(milliseconds: 2000));

    _addBotMessage(
      "Just a quick note: I’m not a licensed specialist and I don’t provide medical advice or diagnoses. "
      "If you ever feel like you need professional help, I can help you connect with one of our verified specialists anytime.",
    );

    await Future.delayed(const Duration(milliseconds: 2000));

    _addBotMessage(
      "So, how are you feeling today?",
    );
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

  int _addUserMessage(String text) {
    final msg = {
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      'isSender': true,
      'status': 'sending',
    };
    setState(() {
      _messages.add(msg);
      _controller.clear();
    });
    _scrollToBottom();
    return _messages.length - 1;
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    // 1️⃣ Add message as "sending"
    final msgIndex = _addUserMessage(content);

    try {
      // 2️⃣ Simulate sending delay (network etc.)
      await Future.delayed(const Duration(seconds: 1));

      // Mark as delivered after 1 second
      setState(() {
        if (msgIndex < _messages.length) {
          _messages[msgIndex]['status'] = 'delivered';
        }
      });

      // 3️⃣ Once delivered, show typing indicator (Calmora typing)
      final typingIndex = _addBotMessage('', isLoading: true);

      // Call Gemini after showing typing (simulate real human timing)
      final aiResponse = await _apiRepository.askGemini(
        content,
        withVoice: _voiceModeEnabled,
        userId: _userId,
      );

      _chatId ??= aiResponse['chatId'];
      final aiReply = aiResponse['reply'];
      final ttsId = aiResponse['id'];
      final ttsPending = aiResponse['ttsPending'] ?? false;

      // 4️⃣ Optional voice playback
      if (_voiceModeEnabled && ttsPending && ttsId != null) {
        String? audioBase64;
        int retries = 0;

        while (audioBase64 == null && retries < 60) {
          await Future.delayed(const Duration(seconds: 1));
          audioBase64 = await _apiRepository.fetchAudio(ttsId);
          retries++;
        }

        if (audioBase64 != null) {
          final audioBytes = base64Decode(audioBase64);
          await _audioPlayer.stop();
          await _audioPlayer.play(BytesSource(audioBytes));
        } else {
          print('Audio not ready after polling.');
        }
      }

      // 5️⃣ Add a short natural typing delay before response appears
      await Future.delayed(const Duration(seconds: 1));

      // Remove typing indicator
      setState(() {
        if (typingIndex < _messages.length) {
          _messages.removeAt(typingIndex);
        }
      });

      // 6️⃣ Show Calmora's reply
      _addBotMessage(aiReply);
    } catch (e) {
      // 7️⃣ If API failed
      setState(() {
        if (msgIndex < _messages.length) {
          _messages[msgIndex]['status'] = 'failed';
        }
      });

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

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onError: (val) {
        print('Speech error: $val');
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (val) async {
        print('Speech status: $val');

        // Detect when speech auto-stops
        if (val == 'notListening' || val == 'done') {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
          // Only stop once, if still active
          if (_speech.isListening) {
            await _stopListeningAndSend();
          }
        }
      },
    );

    if (available) {
      if (mounted) setState(() => _isListening = true);

      _collectedSpeech = '';
      _lastWords = '';

      print("🎙️ Listening...");

      _speech.listen(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        onResult: (val) {
          if (val.finalResult) {
            _collectedSpeech += " ${val.recognizedWords}";
          } else {
            if (mounted) {
              setState(() {
                _controller.text =
                    "${_collectedSpeech.trim()} ${val.recognizedWords}";
              });
            }
          }
        },
      );
    } else {
      print("❌ Speech recognition not available.");
    }
  }

  Future<void> _stopListeningAndSend() async {
    if (!_speech.isAvailable) return;

    print("🛑 Stopping listening...");
    try {
      await _speech.stop();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) setState(() => _isListening = false);

    final spokenText = (_controller.text.trim().isNotEmpty
            ? _controller.text.trim()
            : _collectedSpeech.trim())
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (spokenText.isNotEmpty) {
      print("📤 Sending recognized speech: $spokenText");
      _controller.text = spokenText;
      await _sendMessage();
    } else {
      print("⚠️ No speech detected to send.");
    }

    _collectedSpeech = '';
    _lastWords = '';
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
    final theme = Theme.of(context);

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

              setState(() {
                _voiceModeEnabled = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),

          /// Blurred Overlay
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),
          SizedBox(height: 4),

          /// Foreground Chat UI
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];

                    if (msg['isLoading'] == true) {
                      return const TypingIndicatorBubble(senderName: "Calmora");
                    }

                    return ChatBubble(
                      content: msg['content'],
                      timestamp: _formatTimestamp(msg['timestamp']),
                      status: msg['status'] ?? '',
                      isSender: msg['isSender'],
                      senderName: msg['isSender'] ? 'You' : 'Calmora',
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type a message or use mic...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (_isListening) {
                            print("🛑 Tap detected: stopping listening...");
                            await _stopListeningAndSend();
                          } else {
                            print("🎙️ Tap detected: starting listening...");
                            await _startListening();
                          }
                        },
                        child: Icon(
                          _isListening ? Icons.stop_circle : Icons.mic_none,
                          size: 32,
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
        ],
      ),
    );
  }
}
