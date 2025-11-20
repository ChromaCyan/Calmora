import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      print("⚠️ Supabase already initialized, skipping second init.");
      return;
    }

    print("🔄 Initializing Supabase...");
    await Supabase.initialize(
      // Replace with your own Supabase storage url and key (For Image storing; profile, articles, specialists, specialists id)
      url: 'https://xipqovlvavpygfnzjtpg.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhpcHFvdmx2YXZweWdmbnpqdHBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1NjUwMjUsImV4cCI6MjA2ODE0MTAyNX0.bkCpFtAocbVAPlLir7IOp_MwpeXWvjJc5CTMmwzgQss',
    );
    _client = Supabase.instance.client;
    _isInitialized = true;
    print("✅ Supabase initialized!");
  }

  static Future<SupabaseClient> get client async {
    if (!_isInitialized) {
      print("Supabase not initialized! Initializing now...");
      await initialize();
    }
    return _client!;
  }

  // Upload image to Supabase storage
  static Future<String?> uploadImage(File image, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';

    try {
      final supabase =
          await client; 

      await supabase.storage.from(folder).upload(fileName, image);

      // Generate a signed URL
      final signedUrl = await supabase.storage
          .from(folder)
          .createSignedUrl(fileName, 60 * 60 * 24 * 365);
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
