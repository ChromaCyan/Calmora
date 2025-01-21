import 'package:flutter/material.dart';

class ForgotPasswordDialog extends StatefulWidget {
  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  String currentStep = "verify";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentStep == "verify") ...[
                  const Text(
                    "Change Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Enter your Email:"),
                  const SizedBox(height: 20),
                  _buildTextField("New password:", isPassword: true),
                  const SizedBox(height: 20),
                  _buildTextField("Confirm new password:", isPassword: true),
                  const SizedBox(height: 20),
                  _buildNextButton(setState),
                ] else if (currentStep == "enter_code") ...[
                  const Text(
                    "We’ve sent you a confirmation code, please check your emails (including spams) and enter the code below.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Enter code:"),
                  const SizedBox(height: 20),
                  _buildNextButton(setState),
                ] else if (currentStep == "success") ...[
                  const Icon(Icons.check_circle, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    "Your password has been reset successfully!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String hintText, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildNextButton(StateSetter setState) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (currentStep == "verify") {
            currentStep = "enter_code";
          } else if (currentStep == "enter_code") {
            currentStep = "success";
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
      ),
      child: const Text("Next", style: TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}
