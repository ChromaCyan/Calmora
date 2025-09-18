import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/config/global_loader.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _apiRepository = ApiRepository();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  String _passwordStrength = "";
  String _passwordMatchMessage = "";
  Color _passwordMatchColor = Colors.red;

  String step = "verify"; // verify → enter_code → reset_password → success

  // 🔹 Password strength check
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
      setState(() => _passwordStrength = "Needs Special Character");
    } else {
      setState(() => _passwordStrength = "Strong Password ✅");
    }
  }

  // 🔹 Password match check
  void _checkPasswordMatch() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _passwordMatchMessage = "");
      return;
    }

    if (_newPasswordController.text == _confirmPasswordController.text) {
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

  // 🔹 Handle next steps with API
  Future<void> _handleNextStep() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (step == "verify") {
        if (_emailController.text.isEmpty) {
          throw Exception("Email field cannot be empty.");
        }
        await _apiRepository.requestPasswordReset(_emailController.text.trim());
        setState(() => step = "enter_code");
        FocusScope.of(context).requestFocus(_otpFocus);
      } else if (step == "enter_code") {
        if (_otpController.text.isEmpty) {
          throw Exception("Please enter the OTP code.");
        }

        final response = await _apiRepository.verifyResetOTP(
          _emailController.text.trim(),
          _otpController.text.trim(),
        );

        if (response.containsKey("message") &&
            response["message"] == "OTP verified, proceed to reset password") {
          setState(() => step = "reset_password");
          FocusScope.of(context).requestFocus(_newPasswordFocus);
        } else {
          throw Exception(response["message"] ?? "OTP verification failed.");
        }
      } else if (step == "reset_password") {
        final password = _newPasswordController.text;
        final confirmPassword = _confirmPasswordController.text;

        if (password.isEmpty || confirmPassword.isEmpty) {
          throw Exception("Password fields cannot be empty.");
        }
        if (password != confirmPassword) {
          throw Exception("Passwords do not match!");
        }
        if (_passwordStrength != "Strong Password ✅") {
          throw Exception(
              "Weak password! Must be at least 8 characters, include uppercase, lowercase, a number, and a special character.");
        }

        final response = await _apiRepository.resetPassword(
          _emailController.text.trim(),
          password,
        );

        if (response.containsKey("message") &&
            response["message"] == "Password reset successfully") {
          setState(() => step = "success");
        } else {
          throw Exception(response["message"] ?? "Failed to reset password.");
        }
      } else {
        Navigator.pop(context); // after success
      }
    } catch (e) {
      setState(() => errorMessage = e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: colorScheme.onSurface,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("images/login_bg_image.png", fit: BoxFit.cover),
          Container(
            color: colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Forgot Password",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        if (isLoading)
                          Center(
                            child: GlobalLoader.loader,
                          )
                        else if (step == "verify") ...[
                          Text("Step 1 of 3: Email",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  )),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: "Email",
                            controller: _emailController,
                            focusNode: _emailFocus,
                            keyboardtype: TextInputType.emailAddress,
                          ),
                        ] else if (step == "enter_code") ...[
                          Text("Step 2 of 3: OTP Code",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  )),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: "Enter OTP Code",
                            controller: _otpController,
                            focusNode: _otpFocus,
                            keyboardtype: TextInputType.number,
                          ),
                        ] else if (step == "reset_password") ...[
                          Text("Step 3 of 3: New & Confirm Password",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  )),
                          const SizedBox(height: 10),
                          CustomTextField(
                            label: "New Password",
                            controller: _newPasswordController,
                            focusNode: _newPasswordFocus,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            onChanged: (val) {
                              _checkPasswordStrength(val);
                              _checkPasswordMatch();
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
                            focusNode: _confirmPasswordFocus,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() => _obscureConfirmPassword =
                                    !_obscureConfirmPassword);
                              },
                            ),
                            onChanged: (_) => _checkPasswordMatch(),
                          ),
                          Text(
                            _passwordMatchMessage,
                            style: TextStyle(color: _passwordMatchColor),
                          ),
                        ] else if (step == "success") ...[
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 80),
                          const SizedBox(height: 20),
                          Text("Password Reset Successful!",
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center),
                        ],
                        if (errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(errorMessage!,
                              style: TextStyle(color: colorScheme.error)),
                        ],
                        const SizedBox(height: 40),
                        Center(
                          child: ElevatedButton(
                            onPressed: _handleNextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              child: Text(
                                step == "verify"
                                    ? "Send Code"
                                    : step == "enter_code"
                                        ? "Verify Code"
                                        : step == "reset_password"
                                            ? "Reset Password"
                                            : "Done",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: colorScheme.onSecondary),
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
        ],
      ),
    );
  }
}
