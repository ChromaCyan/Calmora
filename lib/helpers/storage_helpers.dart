import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();

  // Save userId
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  // Save userType
  static Future<void> saveUserType(String userType) async {
    await _storage.write(key: 'userType', value: userType);
  }

  // Get userType
  static Future<String?> getUserType() async {
    return await _storage.read(key: 'userType');
  }

  // Get userId
  static Future<String?> getFirstname() async {
    return await _storage.read(key: 'firstName');
  }

  // Save First Name
  static Future<void> saveUser(String firstName) async {
    await _storage.write(key: 'fisrtName', value: firstName);
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

  static Future<void> saveSurveyCompleted(String userId, bool completed) async {
    await _storage.write(
      key: 'hasCompletedSurvey_$userId',
      value: completed.toString(),
    );
  }

  static Future<bool> getSurveyCompleted(String userId) async {
    final value = await _storage.read(key: 'hasCompletedSurvey_$userId');
    return value == 'true';
  }

  static Future<void> saveSurveyOnboarding(
      String userId, bool completed) async {
    await _storage.write(
      key: 'survey_onboarding_completed_$userId',
      value: completed.toString(),
    );
  }

  static Future<bool> getSurveyOnboarding(String userId) async {
    final value =
        await _storage.read(key: 'survey_onboarding_completed_$userId');
    return value == 'true';
  }
}
