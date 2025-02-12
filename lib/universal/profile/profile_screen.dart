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

        // Set initial values
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
          .subtract(const Duration(days: 365 * 18)), // Minimum age 18
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

    print("✅ User logged out successfully!");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    await _uploadImage(); // Upload image first

    final updatedData = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "phoneNumber": phoneNumberController.text,
      "profileImage": _imageUrl ?? "", // Send empty string if no new image
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
      _fetchProfile(); // Refresh data
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
                      // Profile Picture
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_imageUrl != null
                                        ? NetworkImage(_imageUrl!)
                                        : const AssetImage(
                                            "assets/default-avatar.png"))
                                    as ImageProvider,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: _pickImage,
                          child: const Text("Change Profile Picture"),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Common Fields (Both Patient & Specialist)
                      TextField(
                        controller: firstNameController,
                        decoration:
                            const InputDecoration(labelText: "First Name"),
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: lastNameController,
                        decoration:
                            const InputDecoration(labelText: "Last Name"),
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneNumberController,
                        decoration:
                            const InputDecoration(labelText: "Phone Number"),
                        enabled: isEditing,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: dateOfBirthController,
                        decoration: const InputDecoration(
                          labelText: "Date of Birth",
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: isEditing ? _pickDateOfBirth : null,
                      ),
                      const SizedBox(height: 20),

                      isEditing
                          ? ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text("Save Changes"),
                            )
                          : ElevatedButton(
                              onPressed: () => setState(() => isEditing = true),
                              child: const Text("Edit Profile"),
                            ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CompletedAppointmentsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Appointment History"),
                      ),

                       const SizedBox(height: 20),

                      // Logout Button
                      ElevatedButton(
                        onPressed: () async {
                          await _logout(context);
                        }, // Call the logout function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
