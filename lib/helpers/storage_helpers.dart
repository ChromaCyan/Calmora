import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();

  // Save the User ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'userId', value: userId);
  }

  // Retrieve the stored User ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  // Optional: Clear User ID (for logout or session reset)
  static Future<void> clearUserId() async {
    await _storage.delete(key: 'userId');
  }
}
