import 'package:armstrong/widgets/text/register_built_text_field.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/services/api.dart';

class ForgotPasswordDialog extends StatefulWidget {
  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  String currentStep = "verify";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ApiRepository _apiRepository = ApiRepository();
  bool isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? errorMessage;

  //Password Fields part
  String _passwordStrength = "";
  String _passwordMatchMessage = "";
  Color _passwordMatchColor = Colors.red;

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
    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        _passwordMatchMessage = "";
      });
      return;
    }

    if (newPasswordController.text == confirmPasswordController.text) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else if (currentStep == "verify") ...[
              _buildHeader("Change Password"),
              _buildTextField("Enter your Email:", emailController),
              _buildNextButton(),
            ] else if (currentStep == "enter_code") ...[
              _buildHeader("We've sent a code to your email."),
              _buildTextField("Enter code:", otpController),
              _buildNextButton(),
            ] else if (currentStep == "reset_password") ...[
              _buildHeader("Enter your new password"),
              _buildPasswordField("New password:", newPasswordController, true),

              Text(
                _passwordStrength,
                style: TextStyle(
                  color: _passwordStrength == "Strong Password ✅"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              _buildPasswordField("Confirm new password:", confirmPasswordController, true),

              Text(
                _passwordMatchMessage,
                style: TextStyle(color: _passwordMatchColor),
              ),
              _buildNextButton(),
            ] else if (currentStep == "success") ...[
              Icon(Icons.check_circle, size: 80, color: colorScheme.primary),
              const SizedBox(height: 20),
              _buildHeader("Your password has been reset successfully!"),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: _buttonStyle(),
                child: Text("Close",
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: colorScheme.onPrimary)),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(errorMessage!, style: TextStyle(color: colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

Widget _buildPasswordField(
    String label, TextEditingController controller, bool isNewPassword) {
  bool isVisible =
      isNewPassword ? _isNewPasswordVisible : _isConfirmPasswordVisible;

  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      obscureText: !isVisible,
      onChanged: (value) {
        if (isNewPassword) _checkPasswordStrength(value);
        _checkPasswordMatch();
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              if (isNewPassword) {
                _isNewPasswordVisible = !_isNewPasswordVisible;
              } else {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              }
            });
          },
        ),
      ),
    ),
  );
}


  Widget _buildHeader(String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold, color: colorScheme.onBackground),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomTextField(
        label: label,
        controller: controller,
        obscureText: isPassword,
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () => _handleNextStep(),
      style: _buttonStyle(),
      child: Text("Next",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
    );
  }

  Future<void> _handleNextStep() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (currentStep == "verify") {
        if (emailController.text.isEmpty) {
          throw Exception("Email field cannot be empty.");
        }
        await _apiRepository
            .requestPasswordReset(emailController.text.toLowerCase());
        setState(() => currentStep = "enter_code");
      } else if (currentStep == "enter_code") {
        if (otpController.text.isEmpty) {
          throw Exception("Please enter the OTP code.");
        }

        final response = await _apiRepository.verifyResetOTP(
            emailController.text.toLowerCase(), otpController.text);

        if (response.containsKey("message") &&
            response["message"] == "OTP verified, proceed to reset password") {
          setState(() => currentStep = "reset_password");
        } else {
          throw Exception(
              response["message"] ?? "OTP verification failed. Try again.");
        }
      } else if (currentStep == "reset_password") {
        final password = newPasswordController.text;
        final confirmPassword = confirmPasswordController.text;

        if (password.isEmpty || confirmPassword.isEmpty) {
          throw Exception("Password fields cannot be empty.");
        }
        if (password != confirmPassword) {
          throw Exception("Passwords do not match!");
        }

        // **Enforce Password Strength**
        if (_passwordStrength != "Strong Password ✅") {
          throw Exception(
              "Weak password! Must be at least 8 characters long, include uppercase, lowercase, a number, and a special character.");
        }

        final response = await _apiRepository.resetPassword(
            emailController.text.toLowerCase(), password);

        if (response.containsKey("message") &&
            response["message"] == "Password reset successfully") {
          setState(() => currentStep = "success");
        } else {
          throw Exception(response["message"] ?? "Failed to reset password.");
        }
      }
    } catch (e) {
      setState(() => errorMessage = e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => isLoading = false);
    }
  }
}
