import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
        const SnackBar(content: Text('Please provide feedback and Add Image or selfie during appointment')),
      );
      return;
    }

    final imageUrl = await _uploadImageToSupabase(_image!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image')),
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
          const SnackBar(content: Text('Appointment marked as completed!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(labelText: 'Feedback'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            _image == null
                ? const Text('No image selected')
                : Image.file(_image!, height: 150),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitCompletion,
              child: const Text('Complete Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
