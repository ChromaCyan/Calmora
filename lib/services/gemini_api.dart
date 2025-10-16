import 'dart:convert';
import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ApiRepository {
  final String baseUrl = 'https://calmora-chat-real-time.onrender.com/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<dynamic> askGemini(String message, {bool withVoice = false}) async {
    final url = Uri.parse('$baseUrl/chatbot/ask-ai');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message, 'withVoice': withVoice}),
    );

    if (response.statusCode == 200) {
      if (withVoice) {
        // If backend returns MP3 binary, detect it by checking content type
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.contains('audio') || contentType.contains('mpeg')) {
          return response.bodyBytes; // MP3 bytes
        } else {
          // fallback if backend returns JSON
          return jsonDecode(response.body);
        }
      } else {
        return jsonDecode(response.body);
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Unknown error occurred';
      } catch (_) {
        throw 'Server error: ${response.statusCode}';
      }
    }
  }

  Future<String?> fetchAudio(String id) async {
    final url = Uri.parse('$baseUrl/chatbot/fetch-audio?id=$id');

    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['audioBase64'];
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }
}
