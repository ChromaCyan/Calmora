import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/splash_screen/screens/survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _therapyGoalsController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();

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
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final event = isPatient
          ? RegisterEvent(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              phoneNumber: _phoneNumberController.text,
              password: _passwordController.text,
              otherDetails: {
                "dateOfBirth": _dateOfBirthController.text,
                if (_emergencyContactNameController.text.isNotEmpty)
                  "emergencyContactName": _emergencyContactNameController.text,
                if (_emergencyContactPhoneController.text.isNotEmpty)
                  "emergencyContactPhone":
                      _emergencyContactPhoneController.text,
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
              password: _passwordController.text,
              otherDetails: {
                "specialization": _specializationController.text,
                "licenseNumber": _licenseNumberController.text,
              },
              profileImage: '',
            );

      BlocProvider.of<AuthBloc>(context).add(event);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful!')),
          );

          final userType = state.userData['userType'];

          // Check if the user is a Specialist or Patient
          if (userType == 'Specialist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SpecialistHomeScreen()),
            );
          } else if (userType == 'Patient') {
            // Check if the survey is completed (if not, navigate to the survey screen)
            final FlutterSecureStorage storage = FlutterSecureStorage();
            final hasCompletedSurvey = await storage.read(key: 'hasCompletedSurvey');
            final surveyOnboardingCompleted =
                await storage.read(key: 'survey_onboarding_completed');

            // If survey is completed, navigate to the Patient Home screen
            if (hasCompletedSurvey == 'true' && surveyOnboardingCompleted == 'true') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PatientHomeScreen()),
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
            SnackBar(content: Text('Registration Failed: ${state.message}')),
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
                                  controller: _firstNameController),
                              const SizedBox(height: 20),
                              CustomTextField(
                                  label: "Last Name",
                                  controller: _lastNameController),
                              const SizedBox(height: 20),
                              CustomTextField(
                                  label: "Email", controller: _emailController),
                              const SizedBox(height: 20),
                              CustomTextField(
                                  label: "Phone Number",
                                  controller: _phoneNumberController),
                              const SizedBox(height: 20),
                              CustomTextField(
                                  label: "Password",
                                  controller: _passwordController,
                                  obscureText: true),
                              const SizedBox(height: 20),
                              CustomTextField(
                                  label: "Confirm Password",
                                  controller: _confirmPasswordController,
                                  obscureText: true),
                              const SizedBox(height: 20),
                              if (isPatient) ...[
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: CustomTextField(
                                      label: "Date of Birth",
                                      controller: _dateOfBirthController,
                                      readOnly: true,
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
                                CustomTextField(
                                    label: "Specialization",
                                    controller: _specializationController),
                                const SizedBox(height: 20),
                                CustomTextField(
                                    label: "License Number",
                                    controller: _licenseNumberController),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _onRegisterButtonPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
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
