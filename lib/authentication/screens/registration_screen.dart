import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/config/colors.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/authentication/blocs/auth_event.dart';
import 'package:armstrong/authentication/blocs/auth_state.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:intl/intl.dart';

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), 
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dateOfBirthController.text = formattedDate; 
    }
  }

  void _onRegisterButtonPressed() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final event = isPatient
          ? RegisterEvent(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              email: _emailController.text,
              phoneNumber: _phoneNumberController.text,
              password: _passwordController.text,
              otherDetails: {
                "dateOfBirth": _dateOfBirthController.text,
                if (_emergencyContactNameController.text.isNotEmpty)
                  "emergencyContactName": _emergencyContactNameController.text,
                if (_emergencyContactPhoneController.text.isNotEmpty)
                  "emergencyContactPhone":
                      _emergencyContactPhoneController.text,
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
              password: _passwordController.text,
              otherDetails: {
                "specialization": _specializationController.text,
                "licenseNumber": _licenseNumberController.text,
              },
              profileImage: '',
            );

      BlocProvider.of<AuthBloc>(context).add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration Successful!')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration Failed: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: buttonColor, 
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pop(
                                          context); 
                                    },
                                  ),
                                ],
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
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text("Patient"),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Text("Specialist"),
                                  ),
                                ],
                                color: Colors.black,
                                selectedColor: Colors.white,
                                fillColor: orangeContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                  "First Name", _firstNameController),
                              const SizedBox(height: 20),
                              _buildTextField("Last Name", _lastNameController),
                              const SizedBox(height: 20),
                              _buildTextField("Email", _emailController),
                              const SizedBox(height: 20),
                              _buildTextField(
                                  "Phone Number", _phoneNumberController),
                              const SizedBox(height: 20),
                              _buildTextField("Password", _passwordController,
                                  obscureText: true),
                              const SizedBox(height: 20),
                              _buildTextField("Confirm Password",
                                  _confirmPasswordController,
                                  obscureText: true),
                              const SizedBox(height: 20),
                              if (isPatient) ...[
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: _buildTextField(
                                      "Date of Birth",
                                      _dateOfBirthController,
                                      isRequired: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "Emergency Contact Name (optional)",
                                    _emergencyContactNameController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "Emergency Contact Phone (optional)",
                                    _emergencyContactPhoneController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "Emergency Contact Relation (optional)",
                                    _emergencyContactRelationController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                _buildTextField("Medical History (optional)",
                                    _medicalHistoryController,
                                    isRequired: false),
                                const SizedBox(height: 20),
                                _buildTextField("Therapy Goals (optional)",
                                    _therapyGoalsController,
                                    isRequired: false),
                              ] else ...[
                                _buildTextField("Specialization",
                                    _specializationController),
                                const SizedBox(height: 20),
                                _buildTextField(
                                    "License Number", _licenseNumberController),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _onRegisterButtonPressed,
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
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
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
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool isRequired = true}) {
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
