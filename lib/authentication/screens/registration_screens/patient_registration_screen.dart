import 'dart:ui';

import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:intl/intl.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:armstrong/config/global_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _genderController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Patient-specific fields
  final _dateOfBirthController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _therapyGoalsController = TextEditingController();

  // Focus nodes
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  // UI states
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = "";
  String _passwordMatchMessage = "";
  Color _passwordMatchColor = Colors.red;
  bool _isAgreed = false;

  //Steps Logic
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Register button state
  final ValueNotifier<bool> isRegisterButtonEnabled = ValueNotifier(false);

  InputDecoration customInputDecoration(String label, BuildContext context) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: theme.colorScheme.onSurface),
      filled: false,
      fillColor: Colors.transparent,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  void _checkFields() {
    final isValidEmail = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
        .hasMatch(_emailController.text);
    final isCommonFieldsFilled = _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _genderController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    final isPatientFieldsFilled = _dateOfBirthController.text.isNotEmpty;

    isRegisterButtonEnabled.value =
        isCommonFieldsFilled && isPatientFieldsFilled && _isAgreed;
  }

  final genderOptions = [
    {"label": "Male", "value": "male"},
    {"label": "Female", "value": "female"},
  ];

  void _checkPasswordStrength(String password) {
    if (password.length < 8) {
      setState(() => _passwordStrength = "Too Short");
    } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs Uppercase");
    } else if (!RegExp(r'^(?=.*[a-z])').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs Lowercase");
    } else if (!RegExp(r'^(?=.*\d)').hasMatch(password)) {
      setState(() => _passwordStrength = "Needs a Number");
    } else if (!RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>_\-+=\\/\[\]`~;])')
        .hasMatch(password)) {
      setState(() => _passwordStrength = "Needs a Special Character");
    } else {
      setState(() => _passwordStrength = "Strong Password ✅");
    }
  }

  void _checkPasswordMatch() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _passwordMatchMessage = "");
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

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Stack(
          children: [
            // Centered dialog box
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Material(
                  color: colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  elevation: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              "Calmora Terms & Privacy Notice",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),

                            // Scrollable content
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  '''
Welcome to Calmora! By using this app, you agree to the following:

1. Calmora is a mental health support app connecting users with verified specialists.
2. Your personal data will be stored securely and will never be sold, rented, or shared with third parties without your consent.
3. The information you provide is used solely for app features such as browsing articles, chatting with specialists, booking appointments, or using the AI chatbot.
4. The initial survey is designed to personalize your recommended articles and enhance your overall wellness experience.
5. The AI chatbot provides general emotional and mental wellness support. It is not intended to replace professional therapy, diagnosis, or treatment.
6. All specialists within Calmora are verified by the admin team through submitted certificates or license IDs before their accounts are approved.
7. The Calmora Admins continuously monitor the validity and activity of registered specialists to ensure that only active, verified, and legitimate professionals remain available in the platform.
8. Articles published by specialists undergo admin review and approval to ensure that all content aligns with Calmora’s purpose and values.
9. Articles that are found to be inaccurate, inappropriate, or misleading may be unpublished or removed by the Admin at any time.
10. Calmora prioritizes user safety and data confidentiality at all times, following the principles outlined in the Philippine Mental Health Act of 2018 (RA 11036).
11. While Calmora aims to provide early mental health support and educational resources, it does not guarantee clinical outcomes or replace professional counseling.
12. Calmora is a school project built for educational and wellness purposes, with the goal of promoting accessible, stigma-free mental health care in the Philippines.
''',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(height: 1.6),
                                ),
                              ),
                            ),

                            // Close button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: colorScheme.primaryContainer,
                                  foregroundColor:
                                      colorScheme.onPrimaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.check_rounded, size: 18),
                                label: const Text(
                                  "Close",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
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
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minAllowedDate = DateTime(1900);
    final DateTime maxAllowedDate = DateTime(now.year - 16, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: maxAllowedDate,
      firstDate: minAllowedDate,
      lastDate: maxAllowedDate,
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dateOfBirthController.text = formattedDate;
      _checkFields();
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

    final password = _passwordController.text;
    final strongPasswordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );

    final email = _emailController.text;
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: const AwesomeSnackbarContent(
            title: 'Invalid Email!',
            message: 'Please enter a valid email address.',
            contentType: ContentType.warning,
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

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

    final event = RegisterEvent(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
      gender: _genderController.text,
      password: password,
      otherDetails: {
        "dateOfBirth": _dateOfBirthController.text,
        if (_emergencyContactNameController.text.isNotEmpty)
          "emergencyContactName": _emergencyContactNameController.text,
        if (_emergencyContactPhoneController.text.isNotEmpty)
          "emergencyContactPhone": _emergencyContactPhoneController.text,
        if (_emergencyContactRelationController.text.isNotEmpty)
          "emergencyContactRelation": _emergencyContactRelationController.text,
        if (_medicalHistoryController.text.isNotEmpty)
          "medicalHistory": _medicalHistoryController.text,
        if (_therapyGoalsController.text.isNotEmpty)
          "therapyGoals": _therapyGoalsController.text,
      },
      profileImage: '',
    );

    BlocProvider.of<AuthBloc>(context).add(event);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: colorScheme.onSurface, // ensures visibility in both modes
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.6),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: BlocConsumer<AuthBloc, AuthState>(
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
                        duration: Duration(seconds: 3),
                      ),
                    );

                    final userId = state.userData['userId'];
                    final FlutterSecureStorage storage = FlutterSecureStorage();
                    final hasCompletedSurvey =
                        await storage.read(key: 'hasCompletedSurvey_$userId');
                    final surveyOnboardingCompleted = await storage.read(
                        key: 'survey_onboarding_completed_$userId');

                    if (hasCompletedSurvey == 'true' &&
                        surveyOnboardingCompleted == 'true') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PatientHomeScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
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
                    return GlobalLoader.loader;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 100, horizontal: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "Create Your Account",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          _buildStep(_currentStep),
                          const SizedBox(height: 35),
                          _buildStepperNavigationButtons(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepperNavigationButtons() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        if (_currentStep > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: colorScheme.onPrimary),
              label: Text(
                "Back",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onPrimary),
              ),
            ),
          )
        else
          const SizedBox(width: 20),

        const SizedBox(width: 20), 

        // Next or Sign Up Button
        if (_currentStep < _totalSteps - 1)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep++;
                });
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              label: Text(
                "Next",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onPrimary),
              ),
              icon: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: colorScheme.onPrimary),
            ),
          )
        else
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: isRegisterButtonEnabled,
              builder: (context, isEnabled, child) {
                return ElevatedButton(
                  onPressed: (isEnabled && _isAgreed)
                      ? _onRegisterButtonPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor:
                        isEnabled ? colorScheme.primary : Colors.grey,
                    foregroundColor: isEnabled
                        ? colorScheme.onPrimaryContainer
                        : Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    "Sign up",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStep(int step) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 1: Personal Information",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            CustomTextField(
              label: "First Name",
              controller: _firstNameController,
              focusNode: _firstNameFocus,
              onChanged: (_) => _checkFields(),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Last Name",
              controller: _lastNameController,
              focusNode: _lastNameFocus,
              onChanged: (_) => _checkFields(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _genderController.text.isNotEmpty
                  ? _genderController.text
                  : null,
              decoration: customInputDecoration("Gender", context),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              items: genderOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option["value"],
                  child: Text(option["label"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _genderController.text = value!);
                _checkFields();
              },
            ),
            const SizedBox(height: 20),
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
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 2: Contact Information",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Email",
              controller: _emailController,
              focusNode: _emailFocus,
              onChanged: (_) => _checkFields(),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Phone Number",
              controller: _phoneNumberController,
              focusNode: _phoneFocus,
              keyboardtype: TextInputType.phone,
              onChanged: (_) => _checkFields(),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 3: Set Your Password",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Password",
              controller: _passwordController,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              onChanged: (value) {
                _checkPasswordStrength(value);
                _checkPasswordMatch();
                _checkFields();
              },
            ),
            const SizedBox(height: 8),
            Text(
              _passwordStrength,
              style: TextStyle(
                color: _passwordStrength == "Strong Password ✅"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Confirm Password",
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              onChanged: (_) {
                _checkPasswordMatch();
                _checkFields();
              },
            ),
            const SizedBox(height: 8),
            Text(
              _passwordMatchMessage,
              style: TextStyle(color: _passwordMatchColor),
            ),
            const SizedBox(height: 20),

            // "Read Terms and Conditions" as button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showTermsDialog,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
                icon: Icon(Icons.description_outlined, size: 20, color: colorScheme.onPrimary),
                label: Text(
                  "Read Terms and Conditions",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colorScheme.onPrimary
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: _isAgreed,
                    onChanged: (val) {
                      setState(() {
                        _isAgreed = val ?? false;
                      });
                      _checkFields();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "I have read and agree to the Terms and Conditions",
                    style: TextStyle(fontSize: 15, height: 1.3),
                  ),
                ),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
