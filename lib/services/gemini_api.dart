import 'dart:convert';
import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ApiRepository2 {
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
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // Time Slot with Booking Recreation (The last keep failing)

  // Add a new time slot for the specialist
  Future<Map<String, dynamic>> addTimeSlot({
    required String specialistId,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/timeslot/');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'specialistId': specialistId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

// Update an existing time slot
  Future<Map<String, dynamic>> updateTimeSlot({
    required String slotId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
  }) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/timeslot/$slotId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Delete existing timeslot
  Future<Map<String, dynamic>> deleteTimeSlot(String slotId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/timeslot/$slotId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get available time slots for a specialist
  Future<List<TimeSlotModel>> getAvailableTimeSlots(
    String specialistId,
    DateTime date,
  ) async {
    final token = await _storage.read(key: 'token');
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final url = Uri.parse('$baseUrl/timeslot/$specialistId/$formattedDate');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("API Response: ${response.body}");
      final data = json.decode(response.body);

      if (data["slots"] is List) {
        return (data["slots"] as List).map((slot) {
          return TimeSlotModel.fromJson(slot);
        }).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Unknown error occurred';
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get all slots for a specialist (no date filter)
  Future<List<dynamic>> getAllTimeSlots(String specialistId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/timeslot/$specialistId/all');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("API Response: ${response.body}");
      final data = json.decode(response.body);

      if (data["slots"] is List) {
        return data["slots"] as List<dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Unknown error occurred';
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Book an appointment using timeSlot
  Future<Map<String, dynamic>> bookAppointment(
    String patientId,
    String slotId,
    String message,
    DateTime appointmentDate,
  ) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/timeslot/book');

    String formattedDate =
        "${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}";

    print("Booking appointment with the following details:");
    print("Patient ID: $patientId");
    print("Slot ID: $slotId");
    print("Message: $message");
    print("Appointment Date: $formattedDate");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patientId': patientId,
        'slotId': slotId,
        'message': message,
        'appointmentDate': formattedDate,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }
}
