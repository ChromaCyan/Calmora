import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  TTSService();

  Future<void> initTTS() async {
    List<dynamic> voices = await _flutterTts.getVoices;

    // Print all voices so you can check what's available
    for (var voice in voices) {
      print("Voice: ${voice['name']} - Locale: ${voice['locale']}");
    }

    // Preferred voice priority: Canadian > UK > US
    final preferredVoice = voices.firstWhere(
      (v) => v['locale'] == 'en-CA',
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
      await _flutterTts.setLanguage("en-US");
    }

    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
