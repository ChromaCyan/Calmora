import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();

  // Save userId
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  // Get userId
  static Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  // Clear userId
  static Future<void> clearUserId() async {
    await _storage.delete(key: 'userId');
  }

  // Save JWT (Token)
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  // Get JWT (Token)
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  // Clear JWT (Token)
  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt');
  }

  // Save user role
  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'userType', value: role);
  }

  // Get user role
  static Future<String?> getRole() async {
    return await _storage.read(key: 'userType');
  }

  // Clear user role
  static Future<void> clearRole() async {
    await _storage.delete(key: 'userType');
  }
}
