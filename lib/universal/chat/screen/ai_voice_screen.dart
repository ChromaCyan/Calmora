import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:ui';

enum VoiceChatStatus { idle, listening, loading, playing, error }

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with SingleTickerProviderStateMixin {
  final ApiRepository _apiRepository = ApiRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TTSService _ttsService = TTSService();
  late stt.SpeechToText _speech;

  VoiceChatStatus _status = VoiceChatStatus.idle;
  String _lastWords = '';
  String? _errorMessage;

  late AnimationController _animController;
  bool _useNaturalTTS = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _ttsService.initTTS();

    _ttsService.setOnComplete(() {
      if (mounted) setState(() => _status = VoiceChatStatus.idle);
    });

    _ttsService.setOnCancel(() {
      if (mounted) setState(() => _status = VoiceChatStatus.idle);
    });

    _ttsService.setOnError((msg) {
      print("TTS error: $msg");
      if (mounted) setState(() => _status = VoiceChatStatus.idle);
    });

    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() => _status = VoiceChatStatus.idle);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _status = VoiceChatStatus.listening);
      _speech.listen(
        onResult: (val) {
          setState(() => _lastWords = val.recognizedWords);
        },
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _status = VoiceChatStatus.idle);

    if (_lastWords.trim().isNotEmpty) {
      _sendToAI(_lastWords);
      _lastWords = '';
    }
  }

  Future<void> _sendToAI(String text) async {
    try {
      setState(() => _status = VoiceChatStatus.loading);

      final aiResponse =
          await _apiRepository.askGemini(text, withVoice: _useNaturalTTS);

      final aiReply = aiResponse['reply'];

      if (_useNaturalTTS) {
        // --- NATURAL TTS ---
        final ttsId = aiResponse['id'];
        String? audioBase64;

        // Poll until audio is ready
        int retries = 0;
        while (audioBase64 == null && retries < 60) {
          await Future.delayed(const Duration(seconds: 1));
          audioBase64 = await _apiRepository.fetchAudio(ttsId);
          retries++;
        }

        if (audioBase64 != null) {
          final audioBytes = base64Decode(audioBase64);
          setState(() => _status = VoiceChatStatus.playing);
          await _audioPlayer.play(BytesSource(audioBytes));
        } else {
          setState(() {
            _status = VoiceChatStatus.error;
            _errorMessage = "Failed to play AI response.";
          });
        }
      } else {
        // --- FLUTTER TTS ---
        setState(() => _status = VoiceChatStatus.playing);
        await _ttsService.speak(aiReply);
      }
    } catch (e) {
      setState(() {
        _status = VoiceChatStatus.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _showTTSOptions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Choose TTS Mode"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text("Natural AI Voice"),
              subtitle: const Text(
                  "⚠️ Slower, but more realistic, Response limited to 2-3 sentences"),
              onTap: () {
                setState(() => _useNaturalTTS = true);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.speaker_phone),
              title: const Text("Flutter TTS"),
              subtitle: const Text("Fast, device-based voice"),
              onTap: () {
                setState(() => _useNaturalTTS = false);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String statusText;
    IconData statusIcon;
    Color statusColor;

    switch (_status) {
      case VoiceChatStatus.idle:
        statusText = "Hold to speak";
        statusIcon = Icons.mic_none;
        statusColor = scheme.onBackground;
        break;
      case VoiceChatStatus.listening:
        statusText = "Listening...";
        statusIcon = Icons.mic;
        statusColor = scheme.error;
        break;
      case VoiceChatStatus.loading:
        statusText = "Processing...";
        statusIcon = Icons.hourglass_bottom;
        statusColor = scheme.outline;
        break;
      case VoiceChatStatus.playing:
        statusText = "Speaking...";
        statusIcon = Icons.graphic_eq;
        statusColor = scheme.primary;
        break;
      case VoiceChatStatus.error:
        statusText = _errorMessage ?? "Something went wrong";
        statusIcon = Icons.error;
        statusColor = scheme.error;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calmora Voice Mode"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showTTSOptions,
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),

          /// Blur + semi-transparent overlay
          Container(
            color: scheme.surface.withOpacity(0.5),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const SizedBox.expand(), 
            ),
          ),

          /// Foreground content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated circle
                ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.primaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Mic button
                GestureDetector(
                  onLongPressStart: (_) {
                    if (_status == VoiceChatStatus.idle) _startListening();
                  },
                  onLongPressEnd: (_) {
                    if (_status == VoiceChatStatus.listening) _stopListening();
                  },
                  child: Icon(
                    statusIcon,
                    size: 64,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Status text
                Text(
                  statusText,
                  style: TextStyle(
                    color: scheme.onBackground,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
