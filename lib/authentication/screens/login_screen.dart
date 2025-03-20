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

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
  }

  void _checkFields() {
    final isEnabled =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    isButtonEnabled.value = isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              BlocListener<AuthBloc, AuthState>(
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
                      final FlutterSecureStorage storage =
                          FlutterSecureStorage();
                      final hasCompletedSurvey =
                          await storage.read(key: 'hasCompletedSurvey_$userId');
                      final surveyOnboardingCompleted = await storage.read(
                          key: 'survey_onboarding_completed_$userId');

                      if (hasCompletedSurvey == 'true' &&
                          surveyOnboardingCompleted == 'true') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PatientHomeScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SurveyScreen()),
                        );
                      }
                    } else if (userType == 'Specialist') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SpecialistHomeScreen()),
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
                child: Center(
                  child: Container(
                    width: constraints.maxWidth > 500
                        ? 500
                        : constraints.maxWidth * 0.9,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 250,
                              child: Image.asset(
                                'images/armstrong_transparent.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Login",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            // Email Field
                            CustomTextField(
                              label: "Email:",
                              controller: emailController,
                              obscureText: false,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            CustomTextField(
                              label: "Password:",
                              controller: passwordController,
                              obscureText: _obscureText,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _showForgotPasswordDialog(context);
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
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
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RegistrationScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                ),
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
                                                  password:
                                                      passwordController.text,
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
