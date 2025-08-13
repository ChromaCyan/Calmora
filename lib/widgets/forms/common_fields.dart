// import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class CombinedForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController genderController;
  final TextEditingController dateOfBirthController;

  // Patient-specific fields
  final TextEditingController addressController;
  final TextEditingController medicalHistoryController;
  final TextEditingController therapyGoalsController;
  final TextEditingController emergencyContactNameController;
  final TextEditingController emergencyContactPhoneController;
  final TextEditingController emergencyContactRelationController;

  // Specialist-specific fields
  final TextEditingController specializationController;
  final TextEditingController licenseNumberController;
  final TextEditingController bioController;
  final TextEditingController yearsOfExperienceController;
  final TextEditingController languagesSpokenController;
  final TextEditingController availabilityController;
  final TextEditingController locationController;
  final TextEditingController clinicController;

  final bool isEditing;
  final VoidCallback onPickDateOfBirth;
  final String userType;

  const CombinedForm({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.genderController,
    required this.dateOfBirthController,
    required this.addressController,
    required this.medicalHistoryController,
    required this.therapyGoalsController,
    required this.emergencyContactNameController,
    required this.emergencyContactPhoneController,
    required this.emergencyContactRelationController,
    required this.specializationController,
    required this.licenseNumberController,
    required this.bioController,
    required this.yearsOfExperienceController,
    required this.languagesSpokenController,
    required this.availabilityController,
    required this.locationController,
    required this.clinicController,
    required this.isEditing,
    required this.onPickDateOfBirth,
    required this.userType,
  }) : super(key: key);

  InputDecoration customInputDecoration(String label, BuildContext context,
      {bool readOnly = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: colorScheme.onBackground,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      filled: false,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: isEditing
              ? colorScheme.onSurface.withOpacity(0.5)
              : colorScheme.onSurface.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.primaryContainer,
          width: 2,
        ),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: colorScheme.onSurface.withOpacity(0.1),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  "Personal Information",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        decoration:
                            customInputDecoration("First Name", context),
                        enabled: isEditing,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        decoration: customInputDecoration("Last Name", context),
                        enabled: isEditing,
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: customInputDecoration("Phone Number", context),
                  enabled: isEditing,
                ),
                DropdownButtonFormField<String>(
                  value: genderController.text.isNotEmpty
                      ? genderController.text
                      : null,
                  decoration: customInputDecoration("Gender", context),
                  items: [
                    {"label": "Male", "value": "male"},
                    {"label": "Female", "value": "female"}
                  ].map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender["value"],
                      child: Text(gender["label"]!),
                    );
                  }).toList(),
                  onChanged: isEditing
                      ? (newValue) {
                          genderController.text = newValue!;
                        }
                      : null,
                ),

                // Only show the date picker for patients
                if (userType.toLowerCase() == "patient") ...[
                  GestureDetector(
                    onTap: isEditing ? onPickDateOfBirth : null,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: dateOfBirthController,
                        readOnly: true,
                        decoration: customInputDecoration(
                                "Date of Birth", context,
                                readOnly: true)
                            .copyWith(
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                if (userType.toLowerCase() == "patient") ...[
                    Text (
                    "Medical Information",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: addressController,
                    decoration: customInputDecoration("Address", context),
                    enabled: isEditing,
                  ),
                  TextField(
                    controller: medicalHistoryController,
                    decoration:
                        customInputDecoration("Medical History", context),
                    enabled: isEditing,
                  ),
                  TextField(
                    controller: therapyGoalsController,
                    decoration: customInputDecoration("Therapy Goals", context),
                    enabled: isEditing,
                  ),
                  const SizedBox(height: 20),
                    Text(
                    "Emergency Contact Information",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emergencyContactNameController,
                    decoration: customInputDecoration(
                        "Emergency Contact Name", context),
                    enabled: isEditing,
                  ),
                  TextField(
                    controller: emergencyContactPhoneController,
                    decoration: customInputDecoration(
                        "Emergency Contact Phone", context),
                    enabled: isEditing,
                  ),
                  TextField(
                    controller: emergencyContactRelationController,
                    decoration: customInputDecoration(
                        "Emergency Contact Relation", context),
                    enabled: isEditing,
                  ),
                ],

                if (userType.toLowerCase() == "specialist") ...[
                    Text(
                    "Professional Information",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: specializationController.text.isNotEmpty
                        ? specializationController.text
                        : null,
                    decoration:
                        customInputDecoration("Specialization", context),
                    items: ["Psychologist", "Psychiatrist", "Counselor"]
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? (newValue) {
                            specializationController.text = newValue!;
                          }
                        : null,
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: isEditing ? double.infinity : 100),
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: bioController,
                        decoration: customInputDecoration("Bio", context),
                        enabled: isEditing,
                        maxLines: isEditing ? 4 : null,
                        readOnly: !isEditing,
                      ),
                    ),
                  ),
                  TextField(
                    controller: licenseNumberController,
                    decoration: customInputDecoration("License No.", context),
                    enabled: isEditing,
                  ),
                  TextField(
                    controller: yearsOfExperienceController,
                    decoration:
                        customInputDecoration("Years of Experience", context),
                    enabled: isEditing,
                  ),
                  TextField(
                    controller: languagesSpokenController,
                    decoration:
                        customInputDecoration("Languages Spoken", context),
                    enabled: isEditing,
                  ),
                  // TextField(
                  //   controller: locationController,
                  //   decoration: customInputDecoration("Location", context),
                  //   enabled: isEditing,
                  // ),
                  DropdownButtonFormField<String>(
                    value: locationController.text.isNotEmpty
                        ? locationController.text
                        : null,
                    decoration: customInputDecoration("Location", context),
                    items: ["Dagupan City", "Urdaneta City"]
                        .map((city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ))
                        .toList(),
                    onChanged: isEditing
                        ? (value) {
                            locationController.text = value!;
                          }
                        : null,
                  ),
                  TextField(
                    controller: clinicController,
                    decoration: customInputDecoration("Clinic", context),
                    enabled: isEditing,
                  ),
                  const SizedBox(height: 20),

                    Text(
                    "Work Information",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    value: availabilityController.text.isNotEmpty
                        ? availabilityController.text
                        : null,
                    decoration: customInputDecoration("Availability", context),
                    items: ["Available", "Not Available"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? (newValue) => availabilityController.text = newValue!
                        : null,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
