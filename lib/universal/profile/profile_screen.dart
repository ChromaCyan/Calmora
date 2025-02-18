import 'dart:io';
import 'package:armstrong/specialist/screens/appointments/appointment_complete.dart';
import 'package:armstrong/universal/appointments/appointment_history.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:armstrong/services/api.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:armstrong/universal/profile/profile_picture.dart';
import 'package:armstrong/universal/profile/common_fields.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  bool isEditing = false;
  bool hasError = false;
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  File? _selectedImage;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _apiRepository.getProfile();
      final data = response["data"];

      setState(() {
        profileData = data;
        isLoading = false;

        firstNameController.text = data["firstName"] ?? "";
        lastNameController.text = data["lastName"] ?? "";
        phoneNumberController.text = data["phoneNumber"] ?? "";
        _imageUrl = (data["profileImage"]?.isNotEmpty ?? false)
            ? data["profileImage"]
            : null;
        if (data["dateOfBirth"] != null) {
          _selectedDateOfBirth = DateTime.parse(data["dateOfBirth"]);
          dateOfBirthController.text =
              DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!);
        }
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
          .subtract(const Duration(days: 365 * 18)),
    );

    if (pickedDate != null && pickedDate != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
        dateOfBirthController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      final uploadedUrl =
          await SupabaseService.uploadProfilePicture(_selectedImage!);
      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'userId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    await _uploadImage();

    final updatedData = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "phoneNumber": phoneNumberController.text,
      "profileImage": _imageUrl ?? "",
      "dateOfBirth": _selectedDateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)
          : "",
    };

    try {
      await _apiRepository.editProfile(updatedData);
      setState(() {
        isEditing = false;
        isLoading = false;
      });
      _fetchProfile();
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load profile"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture Widget
                      ProfilePictureWidget(
                        selectedImage: _selectedImage,
                        imageUrl: _imageUrl,
                        onPickImage: _pickImage,
                      ),
                      const SizedBox(height: 20),

                    isEditing
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return Center( // Centers the button
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(constraints.maxWidth * 0.5, 50), // 50% of screen width
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.green, // Green color for Save Changes button
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text("Save Changes"),
                            ),
                          );
                        },
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return Center( // Centers the button
                            child: ElevatedButton(
                              onPressed: () => setState(() => isEditing = true),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(constraints.maxWidth * 0.5, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text("Edit Profile"),
                            ),
                          );
                        },
                      ),


                      const SizedBox(height: 20),

                      // Common Fields Widget
                      CommonFieldsWidget(
                        firstNameController: firstNameController,
                        lastNameController: lastNameController,
                        phoneNumberController: phoneNumberController,
                        dateOfBirthController: dateOfBirthController,
                        isEditing: isEditing,
                        onPickDateOfBirth: _pickDateOfBirth,
                      ),

                      //Appointment History Button
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompletedAppointmentsScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * 0.35,45,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 18,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 5),
                            const Text("Your Appointments"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logout Button
                      const SizedBox(height: 30,),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await _logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
