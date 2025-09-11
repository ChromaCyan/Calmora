// import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'dart:ui';

import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:image_picker/image_picker.dart';
import 'package:armstrong/services/supabase.dart';
import 'dart:io';

class SpecialistRegistrationScreen extends StatefulWidget {
  const SpecialistRegistrationScreen({super.key});

  @override
  State<SpecialistRegistrationScreen> createState() =>
      _SpecialistRegistrationScreenState();
}

class _SpecialistRegistrationScreenState
    extends State<SpecialistRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _genderController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Specialist-specific fields
  final _specializationController = TextEditingController();
  final _locationController = TextEditingController();
  final _clinicController = TextEditingController();

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

  //Image picker Logic
  File? _licenseImage;
  String? _uploadedLicenseUrl;
  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;
  final int _totalSteps = 4;

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

    final isSpecialistFieldsFilled =
        _specializationController.text.isNotEmpty &&
            _locationController.text.isNotEmpty &&
            _clinicController.text.isNotEmpty &&
            _licenseImage != null;

    isRegisterButtonEnabled.value =
        isCommonFieldsFilled && isSpecialistFieldsFilled;
  }

  final genderOptions = [
    {"label": "Male", "value": "male"},
    {"label": "Female", "value": "female"},
  ];

  final specializationOptions = [
    "Psychologist",
    "Psychiatrist",
    "Counselor",
  ];

  final locationOptions = [
    "Dagupan City",
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

  Future<void> _pickLicenseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _licenseImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToSupabase(File image) async {
    return await SupabaseService.uploadAppointmentPicture(image);
  }

  Future<void> _onRegisterButtonPressed() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: const AwesomeSnackbarContent(
            title: 'Missing Fields!',
            message: 'Please fill out all required fields before proceeding.',
            contentType: ContentType.warning,
          ),
          duration: Duration(seconds: 3),
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
          content: const AwesomeSnackbarContent(
            title: 'Password Do Not Match!',
            message: 'Your password does not match, please type it properly...',
            contentType: ContentType.warning,
          ),
          duration: Duration(seconds: 3),
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
          content: const AwesomeSnackbarContent(
            title: 'Weak Password!',
            message:
                'Password must be at least 8 characters long, include an uppercase letter, a lowercase letter, a number, and a special character.',
            contentType: ContentType.warning,
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: const AwesomeSnackbarContent(
            title: 'Missing License!',
            message: 'Please upload your license image before signing up.',
            contentType: ContentType.warning,
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final licenseUrl = await _uploadImageToSupabase(_licenseImage!);

    if (licenseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: const AwesomeSnackbarContent(
            title: 'Upload Failed!',
            message: 'Unable to upload license image. Try again.',
            contentType: ContentType.failure,
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _uploadedLicenseUrl = licenseUrl;

    final event = RegisterEvent(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
      gender: _genderController.text,
      password: password,
      otherDetails: {
        "specialization": _specializationController.text,
        "location": _locationController.text,
        "clinic": _clinicController.text,
        "licenseNumber": _uploadedLicenseUrl!,
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
            color: colorScheme.onSurface,
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
                            title:
                                'Registration Submitted! Your account is pending for review.',
                            message:
                                'Your specialist account is now under review. You will receive an email once it is approved or rejected.',
                            contentType: ContentType.help,
                          ),
                          duration: Duration(seconds: 10),
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
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
        ));
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
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              label: const Text(
                "Back",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        else
          const SizedBox(width: 20),

        const SizedBox(width: 20), // spacing between buttons

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
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              label: const Text(
                "Next",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ),
          )
        else
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: isRegisterButtonEnabled,
              builder: (context, isEnabled, child) {
                return ElevatedButton(
                  onPressed: isEnabled ? _onRegisterButtonPressed : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor:
                        isEnabled ? colorScheme.primaryContainer : Colors.grey,
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
    switch (step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 1: Personal Info",
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
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 2: Specialization & Clinic",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _specializationController.text.isNotEmpty
                  ? _specializationController.text
                  : null,
              decoration: customInputDecoration("Specialization", context),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              items: specializationOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _specializationController.text = value!);
                _checkFields();
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _locationController.text.isNotEmpty
                  ? _locationController.text
                  : null,
              decoration: customInputDecoration("Location", context),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              dropdownColor: Theme.of(context).colorScheme.surface,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              items: locationOptions.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _locationController.text = value!);
                _checkFields();
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Clinic Name",
              controller: _clinicController,
              onChanged: (_) => _checkFields(),
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 3: Upload License",
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Text("Add your license picture (Certificate, Diploma, etc)",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickLicenseImage,
              child: Stack(
                children: [
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      image: _licenseImage != null
                          ? DecorationImage(
                              image: FileImage(_licenseImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _licenseImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 50,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to upload license',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  if (_licenseImage != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _licenseImage = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .background
                                .withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onBackground,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Step 4: Password",
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
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              onChanged: (value) {
                _checkPasswordStrength(value);
                _checkPasswordMatch();
                _checkFields();
              },
            ),
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
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              onChanged: (_) {
                _checkPasswordMatch();
                _checkFields();
              },
            ),
            Text(_passwordMatchMessage,
                style: TextStyle(color: _passwordMatchColor)),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
