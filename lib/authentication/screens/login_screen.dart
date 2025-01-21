import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:armstrong/config/colors.dart';
import 'package:armstrong/authentication/screens/registration_screen.dart';
import 'package:armstrong/widgets/forms/forget_password.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/helpers/storage_helpers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    emailController.addListener(_checkFields);
    passwordController.addListener(_checkFields);
  }

  void _checkFields() {
    final isEnabled = emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
    isButtonEnabled.value = isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/wallpaper.jpg",
              fit: BoxFit.cover,
            ),
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthSuccess) {
                final userData = state.userData;
                final userType = userData['userType'];
                final token = userData['token'];

                // Save the token securely
                await StorageHelper.saveToken(token);

                if (userType == 'Patient') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Welcome, Patient!"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientHomeScreen(),
                    ),
                  );
                } else if (userType == 'Specialist') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Welcome, Specialist"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpecialistHomeScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("You've successfully registered!"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message ?? "Login failed"),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: 500, // Optional: restrict max width
                    ),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 150,
                            child: Image.asset(
                              'images/logo_placeholder.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "Enter your email:",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter your password:",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog(context);
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("No account yet?"),
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
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<bool>(
                            valueListenable: isButtonEnabled,
                            builder: (context, isEnabled, child) {
                              return ElevatedButton(
                                onPressed: isEnabled
                                    ? () {
                                        context.read<AuthBloc>().add(
                                              LoginEvent(
                                                email: emailController.text,
                                                password: passwordController
                                                    .text,
                                              ),
                                            );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: orangeContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 15,
                                  ),
                                  child: Text(
                                    "Log in",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
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
