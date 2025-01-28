import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiRepository {
  final String baseUrl = 'http://localhost:5000/api';
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
    /////////////////////////////////////////////////////////////////////////////////
  // Profile (API)

  // Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch profile: ${response.body}');
    }
  }

  // Edit Profile
  Future<Map<String, dynamic>> editProfile(Map<String, dynamic> updateData) async {
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
  Future<Map<String, dynamic>> getSpecialistById(String specialistId) async {
  final token = await _storage.read(key: 'token');
  final url = Uri.parse('$baseUrl/auth/specialists/$specialistId');
  final response = await http.get(
    url,
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    return json.decode(response.body)['data'];
  } else {
    throw Exception('Failed to fetch specialist details: ${response.body}');
  }
}

  // Get Specialist List
  Future<List<dynamic>> getSpecialistList() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/auth/specialists');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
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
  Future<List<Map<String, dynamic>>> getChatHistory(String chatId, String token) async {
    final url = Uri.parse('$baseUrl/chat/chat-history/$chatId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> chatHistory = json.decode(response.body);
      return chatHistory.map((message) => Map<String, dynamic>.from(message)).toList();
    } else {
      throw Exception('Failed to fetch chat history: ${response.body}');
    }
  }
}
