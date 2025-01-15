import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class ApiRepository {
  final String baseUrl = 'http://localhost:5000/api/';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Register User
  Future<Map<String, dynamic>> registerUser(
    String firstName,
    String lastName,
    String email,
    String password,
    String userType,
    Map<String, dynamic> otherDetails,
  ) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'userType': userType,
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
  Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
    String userType,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
        'userType': userType,
      }),
    );

    if (response.statusCode == 200) {
      // Store the JWT token securely
      final data = json.decode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  }
}
