import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/splash_screen/screens/survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isPatient = true;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _therapyGoalsController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _locationController = TextEditingController();
  final _clinicController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  //Password Fields part
  String _passwordStrength = "";
  String _passwordMatchMessage = "";
  Color _passwordMatchColor = Colors.red;

  // this for the register button lmao, ill add a logic to it later, just don't remove this part please for fuck sake
  final ValueNotifier<bool> isRegisterButtonEnabled = ValueNotifier(false);

  InputDecoration customInputDecoration(String label, BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
      filled: true,
      fillColor: theme.colorScheme.background,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }

  void _checkFields() {
    final isCommonFieldsFilled = _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    final isPatientFieldsFilled =
        isPatient ? _dateOfBirthController.text.isNotEmpty : true;

    final isSpecialistFieldsFilled = !isPatient
        ? _specializationController.text.isNotEmpty &&
            _locationController.text.isNotEmpty &&
            _clinicController.text.isNotEmpty &&
            _licenseNumberController.text.isNotEmpty
        : true;

    isRegisterButtonEnabled.value = isCommonFieldsFilled &&
        isPatientFieldsFilled &&
        isSpecialistFieldsFilled;
  }

  void _checkPasswordStrength(String password) {
    if (password.length < 8) {
      setState(() => _passwordStrength = "Too Short");
    } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs Uppercase");
    } else if (!RegExp(r'^(?=.*[a-z])').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs Lowercase");
    } else if (!RegExp(r'^(?=.*\d)').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs a Number");
    } else if (!RegExp(r'^(?=.*[@$!%*?&])').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs a Special Character");
    } else {
      setState(() => _passwordStrength = "Strong Password ✅");
    }
  }

  void _checkPasswordMatch() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _passwordMatchMessage = "";
      });
      return;
    }

    if (_passwordController.text == _confirmPasswordController.text) {
      setState(() {
        _passwordMatchMessage = "Passwords Match ✅";
        _passwordMatchColor = Colors.green;
      });
    } else {
      setState(() {
        _passwordMatchMessage = "Passwords Do Not Match ❌";
        _passwordMatchColor = Colors.red;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minAllowedDate = DateTime(1900);
    final DateTime maxAllowedDate = DateTime(now.year - 12, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: maxAllowedDate,
      firstDate: minAllowedDate,
      lastDate: maxAllowedDate,
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dateOfBirthController.text = formattedDate;
    }
  }

  void _onRegisterButtonPressed() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Missing Fields!',
            message: 'Please fill out all required fields before proceeding.',
            contentType: ContentType.warning,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Password Do Not Match!',
            message: 'Your password does not match, please type it properly...',
            contentType: ContentType.warning,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Password strength checker
    final password = _passwordController.text;
    final strongPasswordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!strongPasswordRegExp.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Weak Password!',
            message:
                'Password must be at least 8 characters long, include an uppercase letter, a lowercase letter, a number, and a special character.',
            contentType: ContentType.warning,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Bro don't keep fucking removing this part, this shit checks which fields are empty for fuck sake
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Missing Required Fields!',
            message: 'Please ensure all required fields are filled in.',
            contentType: ContentType.warning,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Will go to registration if all shit are good..
    final event = isPatient
        ? RegisterEvent(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            password: password,
            otherDetails: {
              "dateOfBirth": _dateOfBirthController.text,
              if (_emergencyContactNameController.text.isNotEmpty)
                "emergencyContactName": _emergencyContactNameController.text,
              if (_emergencyContactPhoneController.text.isNotEmpty)
                "emergencyContactPhone": _emergencyContactPhoneController.text,
              if (_emergencyContactRelationController.text.isNotEmpty)
                "emergencyContactRelation":
                    _emergencyContactRelationController.text,
              if (_medicalHistoryController.text.isNotEmpty)
                "medicalHistory": _medicalHistoryController.text,
              if (_therapyGoalsController.text.isNotEmpty)
                "therapyGoals": _therapyGoalsController.text,
            },
            profileImage: '',
          )
        : RegisterEvent(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            password: password,
            otherDetails: {
              "specialization": _specializationController.text,
              "location": _locationController.text,
              "clinic": _clinicController.text,
              "licenseNumber": _licenseNumberController.text,
            },
            profileImage: '',
          );

    BlocProvider.of<AuthBloc>(context).add(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Account Created!',
                  message: 'Registration Successful!',
                  contentType: ContentType.success,
                ),
                duration: const Duration(seconds: 3),
              ),
            );

            final userType = state.userData['userType'];
            final userId = state.userData['userId'];

            // Check if the user is a Specialist or Patient
            if (userType == 'Specialist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const SpecialistHomeScreen()),
              );
            } else if (userType == 'Patient') {
              // Check if the survey is completed (if not, navigate to the survey screen)
              final FlutterSecureStorage storage = FlutterSecureStorage();
              final hasCompletedSurvey =
                  await storage.read(key: 'hasCompletedSurvey_$userId');
              final surveyOnboardingCompleted = await storage.read(
                  key: 'survey_onboarding_completed_$userId');

              // If survey is completed, navigate to the Patient Home screen
              if (hasCompletedSurvey == 'true' &&
                  surveyOnboardingCompleted == 'true') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PatientHomeScreen()),
                );
              } else {
                // If survey not completed, navigate to the survey (Splash) screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SurveyScreen()),
                );
              }
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: 'Registration Failed: ${state.message}',
                  contentType: ContentType.failure,
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              ToggleButtons(
                                isSelected: [isPatient, !isPatient],
                                onPressed: (index) {
                                  setState(() {
                                    isPatient = index == 0;
                                  });
                                },
                                children: const [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text("Patient"),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text("Specialist"),
                                  ),
                                ],
                                color: Theme.of(context).colorScheme.onSurface,
                                selectedColor: Colors.white,
                                fillColor:
                                    Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "First Name",
                                controller: _firstNameController,
                                onChanged: (_) => _checkFields(),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Last Name",
                                controller: _lastNameController,
                                onChanged: (_) => _checkFields(),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Email",
                                controller: _emailController,
                                onChanged: (_) => _checkFields(),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Phone Number",
                                controller: _phoneNumberController,
                                onChanged: (_) => _checkFields(),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Password",
                                controller: _passwordController,
                                obscureText: true,
                                onChanged: (value) {
                                  _checkPasswordStrength(value);
                                  _checkPasswordMatch();
                                  _checkFields();
                                },
                              ),
                              Text(
                                _passwordStrength,
                                style: TextStyle(
                                  color:
                                      _passwordStrength == "Strong Password ✅"
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                label: "Confirm Password",
                                controller: _confirmPasswordController,
                                obscureText: true,
                                onChanged: (_) { 
                                  _checkFields();
                                  _checkPasswordMatch();} ,
                              ),
                              Text(
                                _passwordMatchMessage,
                                style: TextStyle(color: _passwordMatchColor),
                              ),
                              const SizedBox(height: 20),
                              if (isPatient) ...[
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: CustomTextField(
                                      label: "Date of Birth",
                                      controller: _dateOfBirthController,
                                      readOnly: true,
                                      onChanged: (_) => _checkFields(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                CustomTextField(
                                    label: "Emergency Contact Name (optional)",
                                    controller: _emergencyContactNameController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                CustomTextField(
                                    label: "Emergency Contact Phone (optional)",
                                    controller:
                                        _emergencyContactPhoneController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                CustomTextField(
                                    label:
                                        "Emergency Contact Relation (optional)",
                                    controller:
                                        _emergencyContactRelationController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                CustomTextField(
                                    label: "Medical History (optional)",
                                    controller: _medicalHistoryController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                CustomTextField(
                                    label: "Therapy Goals (optional)",
                                    controller: _therapyGoalsController,
                                    isRequired: false),
                              ] else ...[
                                DropdownButtonFormField<String>(
                                  value:
                                      _specializationController.text.isNotEmpty
                                          ? _specializationController.text
                                          : null,
                                  decoration: customInputDecoration(
                                      "Specialization", context),
                                  items: [
                                    "Psychologist",
                                    "Psychiatrist",
                                    "Counselor"
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    _specializationController.text = newValue!;
                                    _checkFields();
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Location Dropdown
                                DropdownButtonFormField<String>(
                                  value: _locationController.text.isNotEmpty
                                      ? _locationController.text
                                      : null,
                                  decoration: customInputDecoration(
                                      "Location", context),
                                  items: ["Dagupan City", "Urdaneta City"]
                                      .map((city) => DropdownMenuItem(
                                            value: city,
                                            child: Text(city),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    _locationController.text = value!;
                                    _checkFields();
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Clinic TextField
                                CustomTextField(
                                  label: "Clinic",
                                  controller: _clinicController,
                                  onChanged: (_) => _checkFields(),
                                ),
                                const SizedBox(height: 16),

                                // License Number
                                CustomTextField(
                                  label: "License Number",
                                  controller: _licenseNumberController,
                                  onChanged: (_) => _checkFields(),
                                ),
                                const SizedBox(height: 20),
                              ],
                              const SizedBox(height: 20),
                              ValueListenableBuilder<bool>(
                                valueListenable: isRegisterButtonEnabled,
                                builder: (context, isEnabled, child) {
                                  return ElevatedButton(
                                    onPressed: isEnabled
                                        ? _onRegisterButtonPressed
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isEnabled
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      child: Text(
                                        "Sign up",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
