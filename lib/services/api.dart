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
  final String baseUrl = 'https://armstrong-api.vercel.app/api'; //For real Vercel hosted API
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
      throw Exception('Failed to register user: ${response.body}');
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

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      await _storage.write(key: 'token', value: data['token']);

      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
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
      throw Exception('Failed to verify OTP: ${response.body}');
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
      throw Exception(responseBody['message'] ?? 'Failed to send OTP');
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
      throw Exception("Your OTP has expired. Please request a new one.");
    } else if (responseBody['message'] ==
        "OTP expired after 3 failed attempts. Request a new one.") {
      throw Exception("Too many failed attempts. Request a new OTP.");
    } else {
      throw Exception(responseBody['message'] ?? 'OTP verification failed');
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

  // // Get Profile
  // Future<Map<String, dynamic>> getProfile() async {
  //   final token = await _storage.read(key: 'token');
  //   final url = Uri.parse('$baseUrl/auth/profile');
  //   final response = await http.get(
  //     url,
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to fetch profile: ${response.body}');
  //   }
  // }

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
      throw Exception('Failed to fetch profile: ${response.body}');
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
      throw Exception('Failed to edit profile: ${response.body}');
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
      throw Exception('Failed to fetch specialist details: ${response.body}');
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
      throw Exception('Failed to fetch specialists: ${response.body}');
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
      throw Exception('Failed to fetch patient data: ${response.body}');
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
      throw Exception('Failed to create a new chat: ${response.body}');
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
      throw Exception('Failed to send message: ${response.body}');
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
      throw Exception('Failed to fetch chat list: ${response.body}');
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
      throw Exception('Failed to fetch chat history: ${response.body}');
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
        throw Exception("Invalid data format: Expected list of slots.");
      }
    } else {
      throw Exception('Failed to fetch available slots: ${response.body}');
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
      throw Exception('Failed to create appointment: ${response.body}');
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
      throw Exception('Failed to fetch patient appointments: ${response.body}');
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
      throw Exception(
          'Failed to fetch specialist appointments: ${response.body}');
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
      throw Exception('Failed to accept appointment: ${response.body}');
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
      throw Exception('Failed to decline appointment: ${response.body}');
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
      throw Exception('Failed to complete appointment: ${response.body}');
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
      throw Exception(
          'Failed to fetch completed appointments: ${response.body}');
    }
  }

  // Fetch specialist's weekly completed appointments
  Future<List<dynamic>> getSpecialistWeeklyCompletedAppointments(
    String specialistId, {
    String? startDate,
    String? endDate,
  }) async {
    final token = await _storage.read(key: 'token');

    String url =
        '$baseUrl/appointment/completed/weekly/$specialistId';

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
      throw Exception(
        'Failed to fetch weekly completed appointments: ${response.body}',
      );
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
      throw Exception('Failed to create mood entry: ${response.body}');
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
      throw Exception('Failed to fetch mood entries: ${response.body}');
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////
  // Survey API

  // // Get all surveys
  // Future<List<Survey>> getSurveys() async {
  //   final token = await _storage.read(key: 'token');
  //   final url = Uri.parse('$baseUrl/survey/all');

  //   final response = await http.get(
  //     url,
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body)['data'];
  //     return data.map((surveyJson) => Survey.fromJson(surveyJson)).toList();
  //   } else {
  //     throw Exception('Failed to fetch surveys: ${response.body}');
  //   }
  // }

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
      throw Exception('Failed to fetch surveys: ${response.body}');
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
      throw Exception('Failed to submit survey response: ${response.body}');
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
      throw Exception('Failed to fetch survey results: ${response.body}');
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
      throw Exception('Failed to fetch recommended articles: ${response.body}');
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
      throw Exception('Failed to fetch articles: ${response.body}');
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
      throw Exception('Failed to fetch specialist articles: ${response.body}');
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
      throw Exception('Failed to fetch article: ${response.body}');
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
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create article: ${response.body}');
    }
  }

  // Edit an article
  Future<Map<String, dynamic>> updateArticle({
    required String articleId,
    String? title,
    String? content,
    String? heroImage,
    List<String>? additionalImages,
    List<String>? categories,
  }) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/article/$articleId');

    final Map<String, dynamic> payload = {};

    if (title != null) payload['title'] = title;
    if (content != null) payload['content'] = content;
    if (heroImage != null) payload['heroImage'] = heroImage;
    if (additionalImages != null)
      payload['additionalImages'] = additionalImages;
    if (categories != null) payload['categories'] = categories;

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
      throw Exception('Failed to update article: ${response.body}');
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
      throw Exception('Failed to delete article: ${response.body}');
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
      throw Exception('Failed to load notifications: ${response.body}');
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
      throw Exception('Failed to mark notification as read: ${response.body}');
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
      throw Exception(
          'Failed to mark all notifications as read: ${response.body}');
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
      throw Exception('Failed to add time slot: ${response.body}');
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
      throw Exception('Failed to update time slot: ${response.body}');
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
      throw Exception('Failed to delete time slot: ${response.body}');
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
        throw Exception("Invalid data format: Expected list of slots.");
      }
    } else {
      throw Exception('Failed to fetch available slots: ${response.body}');
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

      // ✅ Fix: Return only the 'slots' list
      if (data["slots"] is List) {
        return data["slots"] as List<dynamic>;
      } else {
        throw Exception("Invalid data format: Expected list of slots.");
      }
    } else {
      throw Exception('Failed to fetch all time slots: ${response.body}');
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
      throw Exception('Failed to book appointment: ${response.body}');
    }
  }

  Future<String> askGemini(String message) async {
  final token = await _storage.read(key: 'token');
  final url = Uri.parse('$baseUrl/chatbot/ask-ai');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      // Uncomment if protected:
      // 'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'message': message,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['reply'];
  } else {
    throw Exception('Gemini error: ${response.body}');
  }
}

}
