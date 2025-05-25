import 'package:armstrong/patient/screens/survey/questions_screen.dart';
import 'package:armstrong/splash_screen/screens/survey_screen.dart';
import 'package:armstrong/widgets/buttons/login_button.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:armstrong/widgets/text/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:armstrong/authentication/screens/registration_screen.dart';
import 'package:armstrong/widgets/forms/forget_password.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/helpers/storage_helpers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);
  bool _obscureText = true;
  bool _showLogo = false;
  


  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
    Future.delayed(const Duration(microseconds: 500), () {
      setState(() {
        _showLogo = true;
      });
    });
  }

  void _checkFields() {
    final isEnabled =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    isButtonEnabled.value = isEnabled;
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Fullscreen background image
              Positioned.fill(
                child: Image.asset(
                  'images/login_bg_image.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Bottom overlay container with glassmorphism
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).size.height * 0.27
                    : MediaQuery.of(context).size.height * 0.5,
                left: 0,
                right: 0,
                bottom: 0,
                child: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) async {
                    if (state is AuthSuccess) {
                      final userData = state.userData;
                      final userType = userData['userType'];
                      final userId = userData['userId'];
                      final token = userData['token'];

                      await StorageHelper.saveUserId(userId);
                      await StorageHelper.saveToken(token);
                      await StorageHelper.saveUserType(userType);

                      if (userType == 'Patient') {
                        final FlutterSecureStorage storage = FlutterSecureStorage();
                        final hasCompletedSurvey = await storage.read(key: 'hasCompletedSurvey_$userId');
                        final surveyOnboardingCompleted = await storage.read(key: 'survey_onboarding_completed_$userId');

                        if (hasCompletedSurvey == 'true' && surveyOnboardingCompleted == 'true') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => PatientHomeScreen()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SurveyScreen()),
                          );
                        }
                      } else if (userType == 'Specialist') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SpecialistHomeScreen()),
                        );
                      }
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Try Again!',
                            message: 'Email or password is incorrect',
                            contentType: ContentType.failure,
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(123),
                      topRight: Radius.circular(123),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(123),
                            topRight: Radius.circular(123),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Center(
                          child: Container(
                            width: constraints.maxWidth > 500
                                ? 500
                                : constraints.maxWidth * 0.9,
                            child: SingleChildScrollView(
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                                left: 16,
                                right: 16,
                                top: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    "LOG IN",
                                    style: GoogleFonts.montserrat(
                                      textStyle: Theme.of(context).textTheme.headlineSmall,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Field
                                  CustomTextField(
                                    label: "Email:",
                                    controller: emailController,
                                    obscureText: false,
                                  ),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  CustomTextField(
                                    label: "Password:",
                                    controller: passwordController,
                                    obscureText: _obscureText,
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureText
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        _showForgotPasswordDialog(context);
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 42),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No account yet?",
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) => RegistrationScreen(),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Sign up",
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: isButtonEnabled,
                                    builder: (context, isEnabled, child) {
                                      return LoginButton(
                                        onTap: isEnabled
                                            ? () {
                                                context.read<AuthBloc>().add(
                                                      LoginEvent(
                                                        email: emailController.text,
                                                        password: passwordController.text,
                                                      ),
                                                    );
                                              }
                                            : null,
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
                ),
              ),
              

              // Overlapping logo
              Positioned(
                top: MediaQuery.of(context).size.height * 0.20 - 150,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1000),
                    opacity: _showLogo ? 1.0 : 0.0,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/armstrong_transparent.png'),
                          fit: BoxFit.cover,
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


  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ForgotPasswordDialog();
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isButtonEnabled.dispose();
    super.dispose();
  }
}
