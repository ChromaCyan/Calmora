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
import 'package:google_fonts/google_fonts.dart';
import 'package:armstrong/universal/profile/setting_screen.dart';
import 'package:armstrong/services/socket_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

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
  final TextEditingController genderController = TextEditingController();
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

  // Clinic Location Fields (GOOGLE MAPS)
  LatLng? _clinicLatLng;
  String? _readableClinicAddress;

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
        genderController.text = user.gender ?? "";
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
          locationController.text = user.location ?? "";
          clinicController.text = user.clinic ?? "";
          availabilityController.text = user.availability ?? "";
          _updateClinicLocationPreview();

          // Patient Fields
          if (_userType == "Patient") {
            addressController.text = user.address ?? "";
            medicalHistoryController.text = user.medicalHistory ?? "";
            therapyGoalsController.text = (user.therapyGoals ?? []).join(", ");

            final emergencyContact = user.emergencyContact;
            emergencyContactNameController.text = emergencyContact?.name ?? "";
            emergencyContactPhoneController.text =
                emergencyContact?.phone ?? "";
            emergencyContactRelationController.text =
                emergencyContact?.relation ?? "";
          }
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
    // 🔌 Disconnect socket
    SocketService().disconnect();

    // 🗑 Clear storage
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'userId');

    // ⬅ Clear entire navigation stack (prevents back button issue)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
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
      "gender": genderController.text,
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

  Future<void> _updateClinicLocationPreview() async {
    try {
      final parts = clinicController.text.split(',');
      if (parts.length < 2) return;

      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      final newLatLng = LatLng(lat, lng);

      final placemarks = await placemarkFromCoordinates(lat, lng);
      String readable = '';
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        readable = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((part) => part != null && part.trim().isNotEmpty).join(', ');
      }

      setState(() {
        _clinicLatLng = newLatLng;
        _readableClinicAddress = readable.isEmpty ? null : readable;
      });
    } catch (e) {
      debugPrint('Error updating clinic location preview: $e');
      setState(() {
        _clinicLatLng = null;
        _readableClinicAddress = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    double titleFontSize = screenWidth * 0.05;
    double bodyFontSize = screenWidth * 0.04;
    double buttonFontSize = screenWidth * 0.045;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "You",
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onPressed: () {
              showFontSettingsPopup(context);
            },
          ),
        ],
      ),
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
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: ProfilePictureWidget(
                            selectedImage: _selectedImage,
                            imageUrl: _imageUrl,
                            onPickImage: isEditing ? _pickImage : () {},
                            isEditing: isEditing,
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Appointment History Button
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CompletedAppointmentsScreen(),
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
                                    icon: Icon(
                                        isEditing ? Icons.save : Icons.edit,
                                        size: 28),
                                    color: isEditing
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.primary,
                                    tooltip: isEditing
                                        ? "Save Changes"
                                        : "Edit Profile",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Combined Form & Logout Button
                        Container(
                          padding: EdgeInsets.all(
                              screenWidth * 0.04), // responsive padding
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
                                genderController: genderController,
                                dateOfBirthController: dateOfBirthController,
                                addressController: addressController,
                                medicalHistoryController:
                                    medicalHistoryController,
                                therapyGoalsController: therapyGoalsController,
                                emergencyContactNameController:
                                    emergencyContactNameController,
                                emergencyContactPhoneController:
                                    emergencyContactPhoneController,
                                emergencyContactRelationController:
                                    emergencyContactRelationController,
                                specializationController:
                                    specializationController,
                                bioController: bioController,
                                yearsOfExperienceController:
                                    yearsOfExperienceController,
                                languagesSpokenController:
                                    languagesSpokenController,
                                availabilityController: availabilityController,
                                locationController: locationController,
                                clinicController: clinicController,
                                isEditing: isEditing,
                                onPickDateOfBirth: _pickDateOfBirth,
                                userType: _userType!,
                              ),

                              if (_userType == "Specialist" &&
                                  _clinicLatLng != null) ...[
                                Text(
                                  'Clinic Location Preview',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: _clinicLatLng!,
                                        zoom: 14,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId:
                                              const MarkerId('clinic_marker'),
                                          position: _clinicLatLng!,
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      liteModeEnabled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                /// 🆕 ADD THIS BLOCK HERE
                                if (licenseNumberController.text.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'License Certificate Provided',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          licenseNumberController.text,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                              ],

                              const SizedBox(height: 20),

                              // Logout Button
                              Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _logout(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    minimumSize: Size(screenWidth * 0.4,
                                        40), // Responsive size
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  child: Text("Logout",
                                      style: TextStyle(
                                          fontSize:
                                              buttonFontSize)), // Dynamic font size
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
