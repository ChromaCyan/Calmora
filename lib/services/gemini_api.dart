import 'dart:convert';
import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/models/user/specialist.dart';
import 'package:armstrong/models/user/user.dart';

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

  // Register User
  Future<Map<String, dynamic>> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String gender,
    String profileImage,
    String otp,
    Map<String, dynamic> otherDetails,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'profileImage': profileImage,
        'otp': otp,
        ...otherDetails,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Send Verification OTP (Before Registration)
  Future<Map<String, dynamic>> sendVerificationOTP(String email) async {
    final url = Uri.parse('$baseUrl/auth/send-verification-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email.toLowerCase()}),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Failed to send verification OTP';
    }
  }

  // Login User
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email.toLowerCase(), 'password': password}),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      final userId = data['userId'];
      final surveyCompleted = data['surveyCompleted'] ?? false;

      // Save token
      await _storage.write(key: 'token', value: token);

      // Save userId
      await _storage.write(key: 'userId', value: userId);

      // Save survey completion flag (scoped to userId)
      await StorageHelper.saveSurveyCompleted(userId, surveyCompleted);

      return data;
    } else {
      final errorMessage = data['message'] ?? 'Failed to login';
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
  ) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Send OTP (Reset Password)
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final url = Uri.parse('$baseUrl/auth/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email.toLowerCase()}),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Verify OTP (Reset Password)
  Future<Map<String, dynamic>> verifyResetOTP(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-reset-otp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email.toLowerCase(), 'otp': otp}),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else if (responseBody['message'] == "OTP has expired") {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    } else if (responseBody['message'] ==
        "OTP expired after 3 failed attempts. Request a new one.") {
      throw Exception("Too many failed attempts. Request a new OTP.");
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Reset Password (Only if OTP was verified)
  Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json
          .encode({'email': email.toLowerCase(), 'newPassword': newPassword}),
    );

    final responseBody = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseBody;
    } else if (responseBody['message'] ==
        "OTP verification required before resetting password") {
      throw Exception("Please verify OTP before resetting your password.");
    } else {
      throw Exception(responseBody['message'] ?? 'Failed to reset password');
    }
  }
}
