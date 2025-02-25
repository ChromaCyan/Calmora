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
      final response = await _apiRepository.getProfile();
      final data = response["data"];

      setState(() {
        profileData = data;
        isLoading = false;
        _userType = data["userType"];

        // Common Fields
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

        // Specialist Fields
        if (_userType == "Specialist") {
          specializationController.text = data["specialization"] ?? "";
          licenseNumberController.text = data["licenseNumber"] ?? "";
          bioController.text = data["bio"] ?? "";
          yearsOfExperienceController.text =
              data["yearsOfExperience"]?.toString() ?? "";
          languagesSpokenController.text =
              (data["languagesSpoken"] as List<dynamic>?)?.join(", ") ?? "";
          availabilityController.text = data["availability"] ?? "";
          locationController.text = data["location"] ?? "";
          clinicController.text = data["clinic"] ?? "";

          //Formating Time to display properly on the form later on (I'm not sure if it works yet please test before changing yung frontend, thanks - josh)
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
              formatTime(data["workingHours"]?["start"] ?? "");
          workingHoursEndController.text =
              formatTime(data["workingHours"]?["end"] ?? "");
        }

        // Patient Fields
        if (_userType == "Patient") {
          addressController.text = data["address"] ?? "";
          medicalHistoryController.text = data["medicalHistory"] ?? "";
          therapyGoalsController.text =
              (data["therapyGoals"] as List<dynamic>?)?.join(", ") ?? "";

          final emergencyContact = data["emergencyContact"] ?? {};
          emergencyContactNameController.text = emergencyContact["name"] ?? "";
          emergencyContactPhoneController.text =
              emergencyContact["phone"] ?? "";
          emergencyContactRelationController.text =
              emergencyContact["relation"] ?? "";
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
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text("Failed to load profile"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
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

                        // Edit/Save Button
                        isEditing
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  return Center(
                                    child: ElevatedButton(
                                      onPressed: _saveProfile,
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(
                                            constraints.maxWidth * 0.5, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
                                      child: const Text("Save Changes"),
                                    ),
                                  );
                                },
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  return Center(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          setState(() => isEditing = true),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(
                                            constraints.maxWidth * 0.5, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                      ),
                                      child: const Text("Edit Profile"),
                                    ),
                                  );
                                },
                              ),

                        const SizedBox(height: 20),

                        // Common Fields Widget
                        CombinedForm(
                          firstNameController: firstNameController,
                          lastNameController: lastNameController,
                          phoneNumberController: phoneNumberController,
                          dateOfBirthController: dateOfBirthController,
                          addressController: addressController,
                          medicalHistoryController: medicalHistoryController,
                          therapyGoalsController: therapyGoalsController,
                          emergencyContactNameController:
                              emergencyContactNameController,
                          emergencyContactPhoneController:
                              emergencyContactPhoneController,
                          emergencyContactRelationController:
                              emergencyContactRelationController,
                          specializationController: specializationController,
                          licenseNumberController: licenseNumberController,
                          bioController: bioController,
                          yearsOfExperienceController:
                              yearsOfExperienceController,
                          languagesSpokenController: languagesSpokenController,
                          availabilityController: availabilityController,
                          locationController: locationController,
                          clinicController: clinicController,
                          workingHoursStartController:
                              workingHoursStartController,
                          workingHoursEndController: workingHoursEndController,
                          isEditing: isEditing,
                          onPickStartTime: () => _pickTime(true),
                          onPickEndTime: () => _pickTime(false),
                          onPickDateOfBirth: _pickDateOfBirth,
                          userType: _userType!,
                        ),

                        const SizedBox(height: 20),

                        // Appointment History Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CompletedAppointmentsScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            minimumSize: Size(
                              MediaQuery.of(context).size.width * 0.35,
                              45,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
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
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _logout(context);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  MediaQuery.of(context).size.width * 0.4, 40),
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
                ),
    );
  }
}
