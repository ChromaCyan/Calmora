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
  Future<Map<String, dynamic>> askGemini(
    String message, {
    bool withVoice = false,
    String? userId,
  }) async {
    final url = Uri.parse('$baseUrl/chatbot/ask-ai');

    final body = {
      'message': message,
      'withVoice': withVoice,
      if (userId != null) 'userId': userId,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
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

  Future<Map<String, dynamic>?> getChatHistory(String userId) async {
    final url = Uri.parse('$baseUrl/chatbot/chat-history/$userId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['error'] ?? 'Failed to load chat history';
    }
  }
}
