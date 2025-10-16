import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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

  String _userSubtitle = '';
  String _fullAIResponse = '';
  String _collectedSpeech = '';

  late AnimationController _animController;
  bool _useNaturalTTS = false;

  String _cleanResponse(String text) {
    return text
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'_'), '')
        .trim();
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    _ttsService.initTTS();

    _ttsService.setOnComplete(() {
      if (mounted)
        setState(() {
          _status = VoiceChatStatus.idle;
          _fullAIResponse = '';
        });
    });

    _ttsService.setOnCancel(() {
      if (mounted)
        setState(() {
          _status = VoiceChatStatus.idle;
          _fullAIResponse = '';
        });
    });

    _ttsService.setOnError((msg) {
      print("TTS error: $msg");
      if (mounted)
        setState(() {
          _status = VoiceChatStatus.idle;
          _fullAIResponse = '';
        });
    });

    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _status = VoiceChatStatus.idle;
        _fullAIResponse = '';
      });
    });
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) async {
        print("Speech status: $status");

        if (status == "done" || status == "notListening") {
          if (mounted && _status == VoiceChatStatus.listening) {
            setState(() => _status = VoiceChatStatus.idle);
          }

          print("🛑 Speech done — stopping automatically...");
          await _stopListening();
        }
      },
      onError: (error) {
        print("Speech error: ${error.errorMsg}");
        if (mounted) setState(() => _status = VoiceChatStatus.error);
      },
    );

    if (!available) {
      print("❌ Speech recognition unavailable");
      setState(() {
        _status = VoiceChatStatus.error;
        _errorMessage = "Speech recognition not available";
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      print("❌ Speech not initialized properly.");
      return;
    }

    _collectedSpeech = '';
    _lastWords = '';

    setState(() {
      _status = VoiceChatStatus.listening;
      _userSubtitle = '';
    });

    print("🎧 Listening for speech...");
    _speech.listen(
      onResult: (val) {
        if (val.recognizedWords.isNotEmpty &&
            val.recognizedWords != _lastWords) {
          setState(() {
            _lastWords = val.recognizedWords;

            // 🧠 Split sentences and limit to last 3
            final sentences = _lastWords.split(RegExp(r'(?<=[.!?])\s+'));
            final trimmed = sentences.length > 3
                ? sentences.sublist(sentences.length - 3).join(' ')
                : _lastWords;

            _userSubtitle = trimmed;
          });

          // Accumulate final results
          if (val.finalResult) {
            _collectedSpeech =
                "${_collectedSpeech.trim()} ${val.recognizedWords.trim()}";
            print("✅ Final recognized: ${val.recognizedWords}");
          } else {
            print("🗣️ Partial: ${val.recognizedWords}");
          }
        }
      },
      listenFor: const Duration(minutes: 15),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      localeId: "en_US",
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _resumeListening() async {
    if (!_speech.isListening && _status == VoiceChatStatus.listening) {
      print("🎧 Resuming listening...");
      await _startListening();
    }
  }

  Future<void> _stopListening() async {
    print("🛑 Stopping listening...");
    await _speech.stop();

    if (mounted) setState(() => _status = VoiceChatStatus.idle);

    await Future.delayed(const Duration(milliseconds: 400));

    final fullSpeech = _collectedSpeech.trim().isNotEmpty
        ? _collectedSpeech.trim()
        : _lastWords.trim();

    if (fullSpeech.isNotEmpty) {
      print("📤 Sending to AI: $fullSpeech");
      await _sendToAI(fullSpeech);
    } else {
      print("⚠️ No speech detected.");
    }

    _collectedSpeech = '';
    _lastWords = '';
    _userSubtitle = '';
  }

  Future<void> _simulateAISubtitles(String text) async {
    List<String> sentences = text.split(RegExp(r'(?<=[.!?]) '));
    for (String s in sentences) {
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _sendToAI(String text) async {
    try {
      setState(() {
        _status = VoiceChatStatus.loading;
        _errorMessage = null;
      });

      final aiResponse =
          await _apiRepository.askGemini(text, withVoice: _useNaturalTTS);

      if (aiResponse == null ||
          aiResponse is! Map ||
          !aiResponse.containsKey('reply')) {
        throw const FormatException("Invalid AI response format");
      }

      final aiReply = _cleanResponse(aiResponse['reply'] ?? '');
      _fullAIResponse = aiReply;

      if (aiReply.isEmpty) throw Exception("Empty AI response");

      if (_useNaturalTTS) {
        final ttsId = aiResponse['id'];
        String? audioBase64;
        int retries = 0;

        while (audioBase64 == null && retries < 100) {
          await Future.delayed(const Duration(seconds: 1));
          audioBase64 = await _apiRepository.fetchAudio(ttsId);
          retries++;
        }

        if (audioBase64 != null) {
          final audioBytes = base64Decode(audioBase64);
          setState(() => _status = VoiceChatStatus.playing);
          _simulateAISubtitles(aiReply);
          await _audioPlayer.play(BytesSource(audioBytes));
        } else {
          throw Exception("Failed to load audio from server");
        }
      } else {
        setState(() => _status = VoiceChatStatus.playing);
        _simulateAISubtitles(aiReply);
        await _ttsService.speak(aiReply);
      }
    } on FormatException {
      setState(() {
        _status = VoiceChatStatus.error;
        _errorMessage = "Something went wrong with the server response.";
      });
    } on Exception catch (e) {
      print("AI request failed: $e");
      setState(() {
        _status = VoiceChatStatus.error;
        _errorMessage =
            "Something went wrong. Please check your internet connection.";
      });
    } catch (e) {
      print("Unexpected error: $e");
      setState(() {
        _status = VoiceChatStatus.error;
        _errorMessage = "An unexpected error occurred. Please try again.";
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
                  "⚠️ Slower, but more realistic, response limited to 2–3 sentences"),
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
        statusText = "Tap to speak";
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

    return WillPopScope(
      onWillPop: () async {
        await _audioPlayer.stop();
        await _ttsService.stop();
        return true;
      },
      child: Scaffold(
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
            Image.asset("images/login_bg_image.png", fit: BoxFit.cover),
            Container(
              color: scheme.surface.withOpacity(0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: const SizedBox.expand(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                          colors: [scheme.primary, scheme.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🎙️ Mic button
                  GestureDetector(
                    onTap: () async {
                      if (_status == VoiceChatStatus.idle) {
                        print("🎤 Listening started...");
                        await _startListening();
                      } else if (_status == VoiceChatStatus.listening) {
                        print("🛑 Listening stopped...");
                        await _stopListening();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _status == VoiceChatStatus.listening
                            ? scheme.error.withOpacity(0.8)
                            : scheme.primary.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_status == VoiceChatStatus.error) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        _errorMessage ??
                            "Something went wrong. Please try again.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.error,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _status = VoiceChatStatus.idle;
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    Text(
                      statusText,
                      style: TextStyle(
                        color: scheme.onBackground,
                        fontSize: 18,
                      ),
                    ),
                  ],

                  // 🧠 Subtitles (User + AI)
                  const SizedBox(height: 50),

                  AnimatedOpacity(
                    opacity: _userSubtitle.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment:
                            Alignment.centerRight, // same as sender alignment
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            _userSubtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_fullAIResponse.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              scheme.primaryContainer.withOpacity(0.9),
                          foregroundColor: scheme.onPrimaryContainer,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("AI Response"),
                              content: SingleChildScrollView(
                                child: Text(
                                  _fullAIResponse,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text("Check AI Response"),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
