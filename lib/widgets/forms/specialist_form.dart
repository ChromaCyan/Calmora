import 'dart:io';
import 'package:flutter/material.dart';

class SpecialistForm extends StatelessWidget {
  final TextEditingController specializationController;
  final TextEditingController licenseNumberController;
  final TextEditingController bioController;
  final TextEditingController yearsOfExperienceController;
  final TextEditingController languagesSpokenController;
  final TextEditingController availabilityController;
  final TextEditingController locationController;
  final TextEditingController clinicController;
  final bool isEditing;

  const SpecialistForm({
    required this.specializationController,
    required this.licenseNumberController,
    required this.bioController,
    required this.yearsOfExperienceController,
    required this.languagesSpokenController,
    required this.availabilityController,
    required this.locationController,
    required this.clinicController,
    required this.isEditing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: specializationController,
          decoration: const InputDecoration(labelText: "Specialization"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: licenseNumberController,
          decoration: const InputDecoration(labelText: "License Number"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: bioController,
          decoration: const InputDecoration(labelText: "Bio"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: yearsOfExperienceController,
          decoration: const InputDecoration(labelText: "Years of Experience"),
          enabled: isEditing,
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: languagesSpokenController,
          decoration: const InputDecoration(labelText: "Languages Spoken"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: availabilityController,
          decoration: const InputDecoration(labelText: "Availability"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: locationController,
          decoration: const InputDecoration(labelText: "Location"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: clinicController,
          decoration: const InputDecoration(labelText: "Clinic"),
          enabled: isEditing,
        ),
      ],
    );
  }
}