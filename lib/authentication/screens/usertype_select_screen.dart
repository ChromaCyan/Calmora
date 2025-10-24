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
import 'dart:ui';
import 'package:armstrong/authentication/screens/registration_screens/patient_registration_screen.dart';
import 'package:armstrong/authentication/screens/registration_screens/specialist_registration_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';

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
  final _genderController = TextEditingController();
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
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  //Password Fields part
  String _passwordStrength = "";
  String _passwordMatchMessage = "";
  Color _passwordMatchColor = Colors.red;

  // this for the register button, I'll add a logic to it later, just don't remove this part please for fuck sake
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
        _genderController.text.isNotEmpty &&
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

    // Password strength checker
    final password = _passwordController.text;
    final strongPasswordRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
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
            gender: _genderController.text,
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
            gender: _genderController.text,
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

// <---Frontend part--->
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new_rounded),
      //     color: colorScheme.onSurface, // adjust color for visibility
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ),
      // extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image
          Image.asset(
            "images/login_bg_image.png", // <-- replace with your asset path
            fit: BoxFit.cover,
          ),

          /// Glass morphism full screen
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.6)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      Text(
                        "Kamusta!",
                        style: GoogleFonts.pacifico(
                          textStyle: Theme.of(context).textTheme.headlineSmall,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          letterSpacing: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(
                        thickness: 1.5,
                        color: Colors.grey,
                        indent: 140,
                        endIndent: 140,
                      ),
                      Text(
                        "Please select which type of user are you",
                        style: GoogleFonts.montserrat(
                          textStyle: Theme.of(context).textTheme.headlineSmall,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 100),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Do you seek help? Register as",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 10),

                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animaiton,
                                                secondaryAnimation) =>
                                            const PatientRegistrationScreen(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                        // builder: (_) => const PatientRegistrationScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    minimumSize:
                                        const Size(double.infinity, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                        colorScheme.primary,
                                    foregroundColor:
                                        colorScheme.onPrimary,
                                  ).copyWith(
                                    overlayColor:
                                        MaterialStateProperty.resolveWith<
                                            Color?>((Set<MaterialState> state) {
                                      if (state
                                          .contains(MaterialState.hovered)) {
                                        return Colors.blue.withOpacity(0.1);
                                      }
                                    }),
                                  ),
                                  child: Text(
                                    "General User",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: colorScheme.onPrimary,
                                        ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              const Divider(
                                thickness: 1.5,
                                color: Colors.grey,
                                indent: 40,
                                endIndent: 40,
                              ),

                              const SizedBox(height: 30),

                              Text(
                                "Do you provide support? Register as",
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 10),

                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const SpecialistRegistrationScreen(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                              opacity: animation, child: child);
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 300),
                                        // builder: (_) => const SpecialistRegistrationScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    minimumSize:
                                        const Size(double.infinity, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                        colorScheme.primary,
                                    foregroundColor:
                                        colorScheme.onPrimary,
                                  ).copyWith(
                                    overlayColor:
                                        MaterialStateProperty.resolveWith<
                                            Color?>((Set<MaterialState> state) {
                                      if (state
                                          .contains(MaterialState.hovered)) {
                                        return Colors.blue.withOpacity(0.1);
                                      }
                                    }),
                                  ),
                                  child: Text(
                                    "Specialist",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: colorScheme.onPrimary,
                                        ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // const Divider(
                              //   thickness: 1.5,
                              //   color: Colors.grey,
                              //   indent: 40,
                              //   endIndent: 40,
                              // ),

                              // const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              LoginScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Log in",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
