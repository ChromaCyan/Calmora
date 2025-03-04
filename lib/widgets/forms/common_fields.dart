import 'package:flutter/material.dart';

class CombinedForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
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
  final TextEditingController workingHoursStartController;
  final TextEditingController workingHoursEndController;

  final bool isEditing;
  final VoidCallback onPickDateOfBirth;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final String userType;

  const CombinedForm({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
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
    required this.workingHoursStartController,
    required this.workingHoursEndController,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.isEditing,
    required this.onPickDateOfBirth,
    required this.userType,
  }) : super(key: key);

   InputDecoration customInputDecoration(String label, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDarkMode ? Colors.blue : Colors.blue),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 3,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: firstNameController,
              decoration: customInputDecoration("First Name", isDarkMode),
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: customInputDecoration("Last Name", isDarkMode),
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: customInputDecoration("Phone Number", isDarkMode),
              enabled: isEditing,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateOfBirthController,
              decoration:
                  customInputDecoration("Date of Birth", isDarkMode).copyWith(
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: isEditing ? onPickDateOfBirth : null,
            ),
            const SizedBox(height: 16),
            if (userType.toLowerCase() == "specialist") ...[
              // Specialist Fields
              DropdownButtonFormField<String>(
                value: specializationController.text.isNotEmpty
                    ? specializationController.text
                    : null,
                decoration: customInputDecoration("Specialization", isDarkMode),
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
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: customInputDecoration("Bio", isDarkMode),
                enabled: isEditing,
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: licenseNumberController,
                  decoration:
                      customInputDecoration("License Number", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              TextField(
                  controller: yearsOfExperienceController,
                  decoration:
                      customInputDecoration("Years of Experience", isDarkMode),
                  enabled: isEditing,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(
                  controller: languagesSpokenController,
                  decoration:
                      customInputDecoration("Languages Spoken", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              // Availability Dropdown
              DropdownButtonFormField<String>(
                value: availabilityController.text.isNotEmpty
                    ? availabilityController.text
                    : null,
                decoration: customInputDecoration("Availability", isDarkMode),
                items: ["Available", "Not available at the moment"]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: isEditing
                    ? (newValue) {
                        availabilityController.text = newValue!;
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: locationController.text.isNotEmpty
                    ? locationController.text
                    : null,
                decoration: customInputDecoration("Location", isDarkMode),
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

              const SizedBox(height: 16),
              TextField(
                  controller: clinicController,
                  decoration: customInputDecoration("Clinic", isDarkMode),
                  enabled: isEditing),

              // Add Working Hours Fields
              const SizedBox(height: 16),
              TextField(
                controller: workingHoursStartController,
                readOnly: true,
                decoration:
                    customInputDecoration("Clinic Appointment Start Time", isDarkMode).copyWith(
                  suffixIcon: Icon(Icons.access_time),
                ),
                onTap: isEditing ? onPickStartTime : null,
              ),

              const SizedBox(height: 16),
              TextField(
                controller: workingHoursEndController,
                readOnly: true,
                decoration:
                    customInputDecoration("Clinic Appointment End Time", isDarkMode).copyWith(
                  suffixIcon: Icon(Icons.access_time),
                ),
                onTap: isEditing ? onPickEndTime : null, 
              ),
            ] else if (userType.toLowerCase() == "patient") ...[
              // Patient Fields
              TextField(
                  controller: addressController,
                  decoration: customInputDecoration("Address", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              TextField(
                  controller: medicalHistoryController,
                  decoration:
                      customInputDecoration("Medical History", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              TextField(
                  controller: therapyGoalsController,
                  decoration:
                      customInputDecoration("Therapy Goals", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              TextField(
                  controller: emergencyContactNameController,
                  decoration: customInputDecoration(
                      "Emergency Contact Name", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              TextField(
                  controller: emergencyContactPhoneController,
                  decoration: customInputDecoration(
                      "Emergency Contact Phone", isDarkMode),
                  enabled: isEditing),
              const SizedBox(height: 16),
              TextField(
                  controller: emergencyContactRelationController,
                  decoration: customInputDecoration(
                      "Emergency Contact Relation", isDarkMode),
                  enabled: isEditing),
            ],
          ],
        ),
      ),
    );
  }
}
