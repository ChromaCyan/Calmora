import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _therapyGoalsController = TextEditingController();
  final _specializationController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/wallpaper.jpg",
              fit: BoxFit.cover, // Ensures the image scales to fill the entire screen
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0), // Adds top and bottom spacing
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        ToggleButtons(
                          isSelected: [isPatient, !isPatient],
                          onPressed: (index) {
                            setState(() {
                              isPatient = index == 0;
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Patient"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Specialist"),
                            ),
                          ],
                          color: Colors.black,
                          selectedColor: Colors.white,
                          fillColor: orangeContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField("First Name", _firstNameController),
                        const SizedBox(height: 20),
                        _buildTextField("Last Name", _lastNameController),
                        const SizedBox(height: 20),
                        _buildTextField("Email", _emailController),
                        const SizedBox(height: 20),
                        _buildTextField("Phone Number", _phoneNumberController),
                        const SizedBox(height: 20),
                        _buildTextField("Password", _passwordController,
                            obscureText: true),
                        const SizedBox(height: 20),
                        _buildTextField("Confirm Password",
                            _confirmPasswordController,
                            obscureText: true),
                        const SizedBox(height: 20),
                        if (isPatient) ...[
                          _buildTextField(
                              "Date of Birth", _dateOfBirthController),
                          const SizedBox(height: 20),
                          _buildTextField("Emergency Contact Name",
                              _emergencyContactNameController),
                          const SizedBox(height: 20),
                          _buildTextField("Emergency Contact Phone",
                              _emergencyContactPhoneController),
                          const SizedBox(height: 20),
                          _buildTextField("Emergency Contact Relation",
                              _emergencyContactRelationController),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Medical History", _medicalHistoryController),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "Therapy Goals", _therapyGoalsController),
                        ],
                        if (!isPatient) ...[
                          _buildTextField(
                              "Specialization", _specializationController),
                          const SizedBox(height: 20),
                          _buildTextField(
                              "License Number", _licenseNumberController),
                        ],
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final event = isPatient
                                  ? RegisterUserEvent(
                                      firstName: _firstNameController.text,
                                      lastName: _lastNameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      userType: 'patient',
                                      otherDetails: {
                                        "dateOfBirth":
                                            _dateOfBirthController.text,
                                        "emergencyContactName":
                                            _emergencyContactNameController
                                                .text,
                                        "emergencyContactPhone":
                                            _emergencyContactPhoneController
                                                .text,
                                        "emergencyContactRelation":
                                            _emergencyContactRelationController
                                                .text,
                                        "medicalHistory":
                                            _medicalHistoryController.text,
                                        "therapyGoals":
                                            _therapyGoalsController.text
                                      },
                                    )
                                  : RegisterUserEvent(
                                      firstName: _firstNameController.text,
                                      lastName: _lastNameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      userType: 'specialist',
                                      otherDetails: {
                                        "specialization":
                                            _specializationController.text,
                                        "licenseNumber":
                                            _licenseNumberController.text,
                                      },
                                    );
                              BlocProvider.of<AuthBloc>(context).add(event);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            child: Text(
                              "Sign up",
                              style: TextStyle(fontSize: 18, color: Colors.white),
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

  Widget _buildTextField(String label, TextEditingController controller,
    {bool obscureText = false, bool isRequired = false}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    ),
    style: const TextStyle(color: Colors.black),
    obscureText: obscureText,
    validator: (value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return "$label is required";
      }
      return null;
    },
  );
}
}
