import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
    return Scaffold(
      // appBar: UniversalAppBar(title: "Complete Appointment"),
      appBar: AppBar(title: Text("Complete Appointmnet"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            Text("Your feedback about your appointment",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
            ),
            const SizedBox(height: 10,),
            TextFormField(
              controller: _feedbackController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Type here',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                hintText: 'Share your thoughts',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.feedback, color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 25),
            Text("Share your memory with your client (^_^)",
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      image: _image != null
                          ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              SizedBox(height: 8),
                              Text('Add image cover',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          )
                        : null,
                  ),

                  // Remove Button (only shown when an image is selected)
                  if (_image != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _image = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Theme.of(context).colorScheme.onBackground, size: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Complete Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitCompletion,
                    icon: Icon(Icons.check_circle),
                    label: Text('Complete Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
