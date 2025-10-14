import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:ui';
// import 'package:armstrong/widgets/navigation/appbar.dart';

class AppointmentCompleteScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentCompleteScreen({required this.appointmentId, Key? key}) : super(key: key);

  @override
  _AppointmentCompleteScreenState createState() => _AppointmentCompleteScreenState();
}

class _AppointmentCompleteScreenState extends State<AppointmentCompleteScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    return await SupabaseService.uploadAppointmentPicture(image);
  }

  Future<void> _submitCompletion() async {
    if (_feedbackController.text.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Try Again!',
            message:
                'Please provide feedback and Add Image or selfie during appointment',
            contentType: ContentType.help,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final imageUrl = await _uploadImageToSupabase(_image!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Try Again!',
            message:
                'Failed to upload image, Please check your network connection',
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final response = await _apiRepository.completeAppointment(
        widget.appointmentId,
        _feedbackController.text,
        imageUrl,
      );

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Appointment Completion submitted!',
            message:
                'Appointment marked as completed!',
            contentType: ContentType.success,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Failed to Complete Appointment!',
            message:
                'Failed to complete appointment, Check your form and try again!',
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'An error has occured!',
            message:
                'Error: $e',
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true, // <-- allows body to resize for keyboard
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        title: Text(
          "Appointment Completion",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),

          /// Frosted blur overlay
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          /// Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    "Your feedback about your appointment",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _feedbackController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Type here',
                      labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      hintText: 'Share your thoughts',
                      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(Icons.feedback, color: theme.colorScheme.onSurfaceVariant),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: theme.colorScheme.outline, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Share your memory with your client (^_^)",
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),

                  /// Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                            image: _image != null
                                ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _image == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,
                                        size: 50,
                                        color: theme.colorScheme.onSurfaceVariant),
                                    SizedBox(height: 8),
                                    Text('Add image cover',
                                        style: TextStyle(
                                            color: theme.colorScheme.onSurfaceVariant)),
                                  ],
                                )
                              : null,
                        ),
                        if (_image != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () => setState(() => _image = null),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.background.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close,
                                    color: theme.colorScheme.onBackground, size: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Complete Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _submitCompletion, 
                        icon: Icon(Icons.send_rounded, size: 24),
                        label: Text(
                          "Submit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 85, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
