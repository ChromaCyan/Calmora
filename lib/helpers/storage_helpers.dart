import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();
  static const _showcaseKey = 'showcase_completed_global';

  
  static Future<bool> getShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showcaseKey) ?? false;
  }

  static Future<void> saveShowcaseCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showcaseKey, true);
  }

  // ===========================
  // USER INFO
  // ===========================

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

  // Save user type / role
  static Future<void> saveUserType(String userType) async {
    await _storage.write(key: 'userType', value: userType);
  }

  static Future<String?> getUserType() async {
    return await _storage.read(key: 'userType');
  }

  static Future<void> clearUserType() async {
    await _storage.delete(key: 'userType');
  }

  // ===========================
  // SURVEY
  // ===========================

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

  static Future<void> resetShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('showcase_completed');
  }
}
