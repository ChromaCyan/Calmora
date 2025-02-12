import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  static SupabaseClient? _client; 
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return; 

    await Supabase.initialize(
      url: 'https://nbjvaoyntnonujntcwbh.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ianZhb3ludG5vbnVqbnRjd2JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxODQ5NTAsImV4cCI6MjA1NDc2MDk1MH0.kJaDZSH5z2XN3717HDnZ5igx7hT5Fjf7KYArorts7eQ',
    );

    _client = Supabase.instance.client; 
    _isInitialized = true;
  }

  static Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      print("Supabase is not initialized! Initializing now...");
      await initialize();
    }
    return _client!;
  }

  // Upload image to Supabase storage
  static Future<String?> uploadImage(File image, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

    try {
      final supabase = await client; // Ensure Supabase is initialized before using it

      await supabase.storage.from(folder).upload(fileName, image);

      // Generate a signed URL
      final signedUrl =
          await supabase.storage.from(folder).createSignedUrl(fileName, 60 * 60 * 24 * 7);
      return signedUrl;
    } catch (e) {
      print('Error uploading image to $folder: $e');
      return null;
    }
  }

  // Upload hero image for articles
  static Future<String?> uploadArticleImage(File image) async {
    return await uploadImage(image, 'article-images');
  }

  // Upload profile picture
  static Future<String?> uploadProfilePicture(File image) async {
    return await uploadImage(image, 'profile-images');
  }

  // Upload appointment complete picture
  static Future<String?> uploadAppointmentPicture(File image) async {
    return await uploadImage(image, 'appointment-images');
  }
}
