import 'package:armstrong/splash_screen/screens/survey_screen.dart';
import 'package:armstrong/widgets/buttons/login_button.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:armstrong/authentication/screens/usertype_select_screen.dart';
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // --- BG Image stays fixed ---
          Positioned.fill(
            child: Image.asset(
              'images/login_bg_image.png',
              fit: BoxFit.cover,
            ),
          ),

          // --- Keyboard-aware area ---
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // --- Logo stays on top ---
                          Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 800),
                              opacity: _showLogo ? 1.0 : 0.0,
                              child: ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    width: 175,
                                    height: 175,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'images/calmora_transparent.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          BlocListener<AuthBloc, AuthState>(
                            listener: _authListener,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(75),
                                topRight: Radius.circular(75),
                              ),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                    left: 36,
                                    right: 36,
                                    top: 32,
                                    bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom +
                                        32,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.6),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(75),
                                      topRight: Radius.circular(75),
                                    ),
                                  ),
                                  child: _buildLoginForm(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 30),
        Text(
          "LOG IN",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headlineSmall,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 30),
        CustomTextField(
          label: "Email:",
          controller: emailController,
          obscureText: false,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: "Password:",
          controller: passwordController,
          obscureText: _obscureText,
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, _, __) => const ForgotPasswordScreen(),
                  transitionsBuilder: (context, animation, _, child) =>
                      FadeTransition(opacity: animation, child: child),
                ),
              );
            },
            child: Text(
              "Forgot Password?",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No account yet?",
                style: Theme.of(context).textTheme.bodyMedium),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, _, __) => RegistrationScreen(),
                    transitionsBuilder: (context, animation, _, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: Text(
                "Sign up",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ValueListenableBuilder<bool>(
          valueListenable: isButtonEnabled,
          builder: (context, isEnabled, child) {
            return LoginButton(
              onTap: isEnabled
                  ? () {
                      context.read<AuthBloc>().add(LoginEvent(
                            email: emailController.text,
                            password: passwordController.text,
                          ));
                    }
                  : null,
            );
          },
        ),
      ],
    );
  }

  void _authListener(BuildContext context, AuthState state) async {
    if (state is AuthSuccess) {
      final userData = state.userData;
      final userType = userData['userType'];
      final userId = userData['userId'];
      final approvalStatus = userData['approvalStatus'];
      final token = userData['token'];
      final surveyCompleted = userData['surveyCompleted'] ?? false;

      if (userType == 'Specialist') {
        if (approvalStatus == 'rejected') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Access Denied',
                message:
                    'Your specialist account was rejected. Please contact support.',
                contentType: ContentType.failure,
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        } else if (approvalStatus == 'pending') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Pending Approval',
                message: 'Your specialist account is still under review.',
                contentType: ContentType.warning,
              ),
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      await StorageHelper.saveUserId(userId);
      await StorageHelper.saveToken(token);
      await StorageHelper.saveUserType(userType);

      if (userType == 'Patient') {
        await StorageHelper.saveSurveyCompleted(userId, surveyCompleted);
        await StorageHelper.saveSurveyOnboarding(userId, false);

        if (surveyCompleted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PatientHomeScreen()),
            (route) => false,
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
      final errorMessage = state.message ?? 'Something went wrong';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Login Failed',
            message: errorMessage,
            contentType: ContentType.failure,
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // void _showForgotPasswordDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return ForgotPasswordDialog();
  //     },
  //   );
  // }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isButtonEnabled.dispose();
    super.dispose();
  }
}
