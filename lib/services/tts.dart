import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  Function()? _onComplete;
  Function()? _onCancel;
  Function(String msg)? _onError;

  TTSService();

  Future<void> initTTS() async {
    List<dynamic> voices = await _flutterTts.getVoices;

    // Print all voices so you can check what's available
    for (var voice in voices) {
      print("Voice: ${voice['name']} - Locale: ${voice['locale']}");
    }

    // Preferred voice priority: Canadian > UK > US
    final preferredVoice = voices.firstWhere(
      (v) => v['locale'] == 'fil-PH',
      orElse: () => voices.firstWhere(
        (v) => v['locale'] == 'en-GB',
        orElse: () => voices.firstWhere(
          (v) => v['locale'] == 'en-US',
          orElse: () => null,
        ),
      ),
    );

    if (preferredVoice != null) {
      await _flutterTts.setVoice({
        "name": preferredVoice['name'],
        "locale": preferredVoice['locale'],
      });
      print(
          "Using voice: ${preferredVoice['name']} (${preferredVoice['locale']})");
    } else {
      print("No preferred English voices found, using default.");
      await _flutterTts.setLanguage("fil-PH");
    }

    await _flutterTts.setPitch(1.1);
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setVolume(1.0);

    // ✅ Attach lifecycle handlers
    _flutterTts.setCompletionHandler(() {
      if (_onComplete != null) _onComplete!();
    });

    _flutterTts.setCancelHandler(() {
      if (_onCancel != null) _onCancel!();
    });

    _flutterTts.setErrorHandler((msg) {
      if (_onError != null) _onError!(msg);
    });
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  // Expose handlers so UI can subscribe
  void setOnComplete(Function() handler) => _onComplete = handler;
  void setOnCancel(Function() handler) => _onCancel = handler;
  void setOnError(Function(String msg) handler) => _onError = handler;
}
