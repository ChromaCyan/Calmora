import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  TTSService();

  Future<void> initTTS() async {
    List<dynamic> voices = await _flutterTts.getVoices;

    for (var voice in voices) {
      print("Voice: $voice");
    }

    await _flutterTts.setVoice({
      "name": "Google UK English Female",
          "locale": "en-GB",
    });

    await _flutterTts.setLanguage("en-GB");
    await _flutterTts.setPitch(1.1);
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
