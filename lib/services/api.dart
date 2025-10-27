import 'dart:convert';
import 'package:armstrong/models/timeslot/timeslot.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

//Model Imports
import 'package:armstrong/models/article/article.dart';
import 'package:armstrong/models/user/user.dart';
import 'package:armstrong/models/survey/survey_result.dart';
import 'package:armstrong/models/survey/survey.dart';
import 'package:armstrong/models/mood/mood.dart';
import 'package:armstrong/models/user/specialist.dart';

class ApiRepository {
  final String baseUrl =
      'https://armstrong-api.vercel.app/api'; //For real Vercel hosted API
  //final String baseUrl = 'http://localhost:3000/api'; //For Vercel Dev testing
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /////////////////////////////////////////////////////////////////////////////////
  //Authentication (API)

  // Register User
  Future<Map<String, dynamic>> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
    String gender,
    String profileImage,
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

  /////////////////////////////////////////////////////////////////////////////////
  // Profile (API)

  // Get Profile
  Future<Profile> getProfile() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)["data"];
      return Profile.fromJson(data);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Edit Profile
  Future<Map<String, dynamic>> editProfile(
      Map<String, dynamic> updateData) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updateData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get Specialist by ID
  Future<Specialist> fetchSpecialistById(String specialistId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/specialists/$specialistId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Specialist.fromJson(json.decode(response.body)['data']);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get Specialist List
  Future<List<Specialist>> fetchSpecialists() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/specialists');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Specialist.fromJson(json)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get Patient Data
  Future<Map<String, dynamic>> getPatientData() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/patient-data');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }
  /////////////////////////////////////////////////////////////////////////////////
  //Chat (API)

  Future<String?> getExistingChatId(String recipientId, String token) async {
    final chatList = await getChatList(token);
    for (var chat in chatList) {
      final participants = chat['participants'] as List<dynamic>;
      if (participants
          .any((participant) => participant['_id'] == recipientId)) {
        return chat['chatId'];
      }
    }
    return null;
  }

  Future<String> createChat(String recipientId, String token) async {
    final url = Uri.parse('$baseUrl/chat/create-chat');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'recipientId': recipientId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['chatId']; // Return the chatId for the new chat
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Send message API
  Future<void> sendMessage(String chatId, String content, String token) async {
    final url = Uri.parse('$baseUrl/chat/send-message');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'chatId': chatId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get chat list API
  Future<List<Map<String, dynamic>>> getChatList(String token) async {
    final url = Uri.parse('$baseUrl/chat/chat-list');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> chatList = json.decode(response.body);
      return chatList.map((chat) => Map<String, dynamic>.from(chat)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get chat history API
  Future<List<Map<String, dynamic>>> getChatHistory(
      String chatId, String token) async {
    final url = Uri.parse('$baseUrl/chat/chat-history/$chatId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> chatHistory = json.decode(response.body);
      return chatHistory
          .map((message) => Map<String, dynamic>.from(message))
          .toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }
  /////////////////////////////////////////////////////////////////////////////////
  // Appointments (API)

  // Get available time slots from specialist
  Future<List<DateTime>> fetchAvailableTimeSlots(
      String specialistId, DateTime date) async {
    final token = await _storage.read(key: 'token');
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = Uri.parse(
        '$baseUrl/appointment/available-slots/$specialistId/$formattedDate');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["availableSlots"] is List) {
        return (data["availableSlots"] as List).map((slot) {
          // Extract "HH:MM" and convert to DateTime
          final timeParts = slot["start"].split(":").map(int.parse).toList();
          return DateTime(
              date.year, date.month, date.day, timeParts[0], timeParts[1]);
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

  // Create a new appointment
  Future<Map<String, dynamic>> addAppointment(
    String patientId,
    String specialistId,
    DateTime startTime,
    String message,
  ) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/create-appointment');

    // Ensure correct format for backend comparison
    String formattedStartTime = startTime.toUtc().toIso8601String();

    // Print the request body before making the API call
    print("Creating appointment with the following details:");
    print("Patient ID: $patientId");
    print("Specialist ID: $specialistId");
    print("Start Time: $formattedStartTime");
    print("Message: $message");

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patientId': patientId,
        'specialistId': specialistId,
        'startTime': formattedStartTime,
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get all appointments for a patient
  Future<List<dynamic>> getPatientAppointments(String patientId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/patient/$patientId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get all appointments for a specialist
  Future<List<dynamic>> getSpecialistAppointments(String specialistId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/specialist/$specialistId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Specialist accepts an appointment
  Future<Map<String, dynamic>> acceptAppointment(String appointmentId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/$appointmentId/accept');
    final response = await http.put(
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

  // Specialist declines an appointment
  Future<Map<String, dynamic>> declineAppointment(String appointmentId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/$appointmentId/decline');
    final response = await http.put(
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

  // Mark an appointment as completed
  Future<Map<String, dynamic>> completeAppointment(
    String appointmentId,
    String feedback,
    String imageUrl,
  ) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/$appointmentId/complete');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'feedback': feedback,
        'imageUrl': imageUrl,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Fetch completed appointments
  Future<List<dynamic>> getCompletedAppointments(String userId) async {
    final token = await _storage.read(key: 'token');
    final url =
        Uri.parse('$baseUrl/appointment/appointments/completed/$userId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Fetch specialist's weekly completed appointments
  Future<List<dynamic>> getSpecialistWeeklyCompletedAppointments(
    String specialistId, {
    String? startDate,
    String? endDate,
  }) async {
    final token = await _storage.read(key: 'token');

    String url = '$baseUrl/appointment/completed/weekly/$specialistId';

    if (startDate != null && endDate != null) {
      url += '?startDate=$startDate&endDate=$endDate';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Reschedule an appointment (for both Patient and Specialist)
  Future<Map<String, dynamic>> rescheduleAppointment(
    String appointmentId,
    String newSlotId,
    DateTime newDate,
    String requestedBy, // "patient" or "specialist"
  ) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/$appointmentId/reschedule');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'newSlotId': newSlotId,
        'newDate': newDate.toIso8601String(),
        'requestedBy': requestedBy,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['error'] ?? 'Unknown error occurred';
    }
  }

  // Cancel an appointment (for both Patient and Specialist)
  Future<Map<String, dynamic>> cancelAppointment(
    String appointmentId,
    String cancelledBy,
    String reason,
  ) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/appointment/$appointmentId/cancel');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'cancelledBy': cancelledBy, // "patient" or "specialist"
        'reason': reason,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['error'] ?? 'Unknown error occurred';
    }
  }

  /////////////////////////////////////////////////////////////////////////////////
  // Mood (API)
  // Create Mood Entry
  Future<Map<String, dynamic>> createMoodEntry(
      int moodScale, String moodDescription) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/mood/create-mood');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'moodScale': moodScale,
        'moodDescription': moodDescription,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get Mood Entries
  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/mood/mood-entries/$userId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => MoodEntry.fromJson(item)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // Survey API

  // Get all surveys
  Future<List<Map<String, dynamic>>> getSurveys() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/survey/all');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((survey) => Map<String, dynamic>.from(survey)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Submit survey response (Patient only)
  Future<Map<String, dynamic>> submitSurveyResponse(
      String patientId,
      String surveyId,
      List<Map<String, dynamic>> responses,
      String category) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/survey/submit');

    print('Submitting survey response with data:');
    print({
      'patientId': patientId,
      'surveyId': surveyId,
      'responses': responses,
      'category': category,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'patientId': patientId,
        'surveyId': surveyId,
        'responses': responses,
        'category': category,
      }),
    );

    print('Response from API: ${response.body}');

    if (response.statusCode == 201) {
      return json.decode(response.body)['data'];
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Mark survey as completed (Skip Survey)
  Future<void> markSurveyCompleted(String patientId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/survey/$patientId/survey-completed');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Failed to mark survey as completed';
    }
  }

  // Get survey results for a patient
  Future<SurveyResult> getPatientSurveyResults(String patientId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/survey/results/$patientId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body)['data'];
      return SurveyResult.fromJson(data);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Get recommended articles based on the patient's latest survey interpretation
  Future<List<Article>> getRecommendedArticles(String patientId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/survey/$patientId/recommended-articles');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Convert each item to an Article object
      return data.map((articleData) => Article.fromMap(articleData)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // Article API

  // Fetch all articles
  Future<List<Article>> getAllArticles() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/articles');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((article) => Article.fromMap(article)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Fetch articles by specialist
  Future<List<Article>> getArticlesBySpecialist(String specialistId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/specialist/$specialistId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((article) => Article.fromMap(article)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Fetch a single article by ID
  Future<Article> getArticleById(String articleId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/$articleId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Article.fromMap(data);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Create a new article
  Future<Map<String, dynamic>> createArticle({
    required String title,
    required String content,
    required String heroImage,
    List<String>? additionalImages,
    required String specialistId,
    required List<String> categories,
    required String targetGender,
  }) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/create-article');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'heroImage': heroImage,
        'additionalImages': additionalImages ?? [],
        'specialistId': specialistId,
        'categories': categories,
        'targetGender': targetGender,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Edit an article
  Future<Map<String, dynamic>> updateArticle(
      {required String articleId,
      String? title,
      String? content,
      String? heroImage,
      List<String>? additionalImages,
      List<String>? categories,
      String? targetGender}) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/$articleId');

    final Map<String, dynamic> payload = {};

    if (title != null) payload['title'] = title;
    if (content != null) payload['content'] = content;
    if (heroImage != null) payload['heroImage'] = heroImage;
    if (additionalImages != null)
      payload['additionalImages'] = additionalImages;
    if (categories != null) payload['categories'] = categories;
    if (targetGender != null) payload['targetGender'] = targetGender;

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Delete an article
  Future<void> deleteArticle(String articleId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/$articleId');

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // Notification API

  // Fetch all notifications for a user
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/notification/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/notification/mark-read/$notificationId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/notification/mark-all/$userId');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw errorData['message'] ?? 'Unknown error occurred';
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

  Future<Map<String, dynamic>?> getAIChatHistory(String userId) async {
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
