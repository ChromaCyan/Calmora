import 'dart:io';
import 'package:armstrong/universal/appointments/appointment_history.dart';
import 'package:armstrong/widgets/forms/patient_form.dart';
import 'package:armstrong/widgets/forms/specialist_form.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/services/supabase.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:armstrong/widgets/forms/profile_picture.dart';
import 'package:armstrong/widgets/forms/common_fields.dart';
import 'package:armstrong/models/user/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //Map<String, dynamic>? profileData;
  Profile? profileData;
  bool isLoading = true;
  bool isEditing = false;
  bool hasError = false;
  final ApiRepository _apiRepository = ApiRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Common Fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  // Specialist Fields
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController yearsOfExperienceController =
      TextEditingController();
  final TextEditingController languagesSpokenController =
      TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController workingHoursStartController =
      TextEditingController();
  final TextEditingController workingHoursEndController =
      TextEditingController();
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  // Patient Fields
  final TextEditingController addressController = TextEditingController();
  final TextEditingController medicalHistoryController =
      TextEditingController();
  final TextEditingController therapyGoalsController = TextEditingController();
  final TextEditingController emergencyContactNameController =
      TextEditingController();
  final TextEditingController emergencyContactPhoneController =
      TextEditingController();
  final TextEditingController emergencyContactRelationController =
      TextEditingController();

  File? _selectedImage;
  String? _imageUrl;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await _apiRepository.getProfile(); // Fetching the Profile
      setState(() {
        profileData = user; // Assign the Profile object to profileData
        isLoading = false;
        _userType = user.userType;

        // Common Fields
        firstNameController.text = user.firstName ?? "";
        lastNameController.text = user.lastName ?? "";
        phoneNumberController.text = user.phoneNumber ?? "";
        _imageUrl =
            user.profileImage?.isNotEmpty ?? false ? user.profileImage : null;

        if (user.dateOfBirth != null) {
          _selectedDateOfBirth = user.dateOfBirth;
          dateOfBirthController.text =
              DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!);
        }

        // Specialist Fields
        if (_userType == "Specialist") {
          specializationController.text = user.specialization ?? "";
          licenseNumberController.text = user.licenseNumber ?? "";
          bioController.text = user.bio ?? "";
          yearsOfExperienceController.text =
              user.yearsOfExperience?.toString() ?? "";
          languagesSpokenController.text =
              (user.languagesSpoken ?? []).join(", ");
          availabilityController.text = user.availability ?? "";

          // Formatting Time for working hours
          String formatTime(String time) {
            if (time.isEmpty) return "";
            final parts = time.split(":");
            int hour = int.parse(parts[0]);
            int minute = int.parse(parts[1]);
            String period = hour >= 12 ? "PM" : "AM";
            hour = hour % 12 == 0 ? 12 : hour % 12;

            return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
          }

          workingHoursStartController.text =
              formatTime(user.workingHoursStart ?? "");
          workingHoursEndController.text =
              formatTime(user.workingHoursEnd ?? "");
        }

        // Patient Fields
        if (_userType == "Patient") {
          addressController.text = user.address ?? "";
          medicalHistoryController.text = user.medicalHistory ?? "";
          therapyGoalsController.text = (user.therapyGoals ?? []).join(", ");

          final emergencyContact = user.emergencyContact;
          emergencyContactNameController.text = emergencyContact?.name ?? "";
          emergencyContactPhoneController.text = emergencyContact?.phone ?? "";
          emergencyContactRelationController.text =
              emergencyContact?.relation ?? "";
        }
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_selectedStartTime ?? TimeOfDay.now())
          : (_selectedEndTime ?? TimeOfDay.now()),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = pickedTime;
          workingHoursStartController.text = pickedTime.format(context);
        } else {
          _selectedEndTime = pickedTime;
          workingHoursEndController.text = pickedTime.format(context);
        }
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
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

  //Save Functionality
  Future<void> _saveProfile() async {
    setState(() => isLoading = true);

    await _uploadImage();

    final Map<String, dynamic> updatedData = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "phoneNumber": phoneNumberController.text,
      "profileImage": _imageUrl ?? "",
      "dateOfBirth": _selectedDateOfBirth != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!)
          : "",
    };

    if (_userType == "Specialist") {
      updatedData.addAll({
        "specialization": specializationController.text,
        "licenseNumber": licenseNumberController.text,
        "bio": bioController.text,
        "yearsOfExperience": yearsOfExperienceController.text,
        "languagesSpoken": languagesSpokenController.text,
        "availability": availabilityController.text,
        "clinic": clinicController.text,
        "location": locationController.text,
        "workingHours": {
          "start": workingHoursStartController.text,
          "end": workingHoursEndController.text,
        },
      });
    } else if (_userType == "Patient") {
      updatedData.addAll({
        "address": addressController.text,
        "medicalHistory": medicalHistoryController.text,
        "therapyGoals": therapyGoalsController.text,
        "emergencyContact": {
          "name": emergencyContactNameController.text,
          "phone": emergencyContactPhoneController.text,
          "relation": emergencyContactRelationController.text,
        },
      });
    }

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
  final theme = Theme.of(context);
  final screenSize = MediaQuery.of(context).size;
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;

  // Calculate dynamic font sizes
  double titleFontSize = screenWidth * 0.05; // 5% of screen width
  double bodyFontSize = screenWidth * 0.04; // 4% of screen width
  double buttonFontSize = screenWidth * 0.045; // 4.5% of screen width

  return Scaffold(
    appBar: AppBar(title: Text("Profile", style: TextStyle(fontSize: titleFontSize))),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasError
            ? const Center(child: Text("Failed to load profile"))
            : SingleChildScrollView(
                child: Container(
                  color: theme.colorScheme.primaryContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Profile Picture Container
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04), // responsive padding
                        child: ProfilePictureWidget(
                          selectedImage: _selectedImage,
                          imageUrl: _imageUrl,
                          onPickImage: isEditing ? _pickImage : () {},
                          isEditing: isEditing,
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // responsive padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Appointment History Button
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CompletedAppointmentsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history, size: 28),
                              color: Theme.of(context).colorScheme.secondary,
                              tooltip: "Appointment History",
                            ),

                            // Edit/Save & Cancel Buttons
                            Row(
                              children: [
                                if (isEditing)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditing = false;
                                        // Reset fields logic...
                                      });
                                    },
                                    icon: const Icon(Icons.close, size: 28),
                                    color: Colors.red,
                                    tooltip: "Cancel Edit",
                                  ),
                                IconButton(
                                  onPressed: () {
                                    if (isEditing) {
                                      _saveProfile();
                                    } else {
                                      setState(() => isEditing = true);
                                    }
                                  },
                                  icon: Icon(isEditing ? Icons.save : Icons.edit, size: 28),
                                  color: isEditing ? Colors.green : Theme.of(context).colorScheme.primary,
                                  tooltip: isEditing ? "Save Changes" : "Edit Profile",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Combined Form & Logout Button
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04), // responsive padding
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Form
                            CombinedForm(
                              firstNameController: firstNameController,
                              lastNameController: lastNameController,
                              phoneNumberController: phoneNumberController,
                              dateOfBirthController: dateOfBirthController,
                              addressController: addressController,
                              medicalHistoryController: medicalHistoryController,
                              therapyGoalsController: therapyGoalsController,
                              emergencyContactNameController: emergencyContactNameController,
                              emergencyContactPhoneController: emergencyContactPhoneController,
                              emergencyContactRelationController: emergencyContactRelationController,
                              specializationController: specializationController,
                              licenseNumberController: licenseNumberController,
                              bioController: bioController,
                              yearsOfExperienceController: yearsOfExperienceController,
                              languagesSpokenController: languagesSpokenController,
                              availabilityController: availabilityController,
                              locationController: locationController,
                              clinicController: clinicController,
                              workingHoursStartController: workingHoursStartController,
                              workingHoursEndController: workingHoursEndController,
                              isEditing: isEditing,
                              onPickStartTime: () => _pickTime(true),
                              onPickEndTime: () => _pickTime(false),
                              onPickDateOfBirth: _pickDateOfBirth,
                              userType: _userType!,
                            ),

                            const SizedBox(height: 20),

                            // Logout Button
                            Center(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _logout(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(screenWidth * 0.4, 40), // Responsive size
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Text("Logout", style: TextStyle(fontSize: buttonFontSize)), // Dynamic font size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  );
}
}
