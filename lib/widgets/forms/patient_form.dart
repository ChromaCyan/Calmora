import 'dart:io';
import 'package:flutter/material.dart';

class PatientForm extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController medicalHistoryController;
  final TextEditingController therapyGoalsController;
  final TextEditingController emergencyContactNameController;
  final TextEditingController emergencyContactPhoneController;
  final TextEditingController emergencyContactRelationController;
  final bool isEditing;

  const PatientForm({
    required this.addressController,
    required this.medicalHistoryController,
    required this.therapyGoalsController,
    required this.emergencyContactNameController,
    required this.emergencyContactPhoneController,
    required this.emergencyContactRelationController,
    required this.isEditing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(labelText: "Address"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: medicalHistoryController,
          decoration: const InputDecoration(labelText: "Medical History"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: therapyGoalsController,
          decoration: const InputDecoration(labelText: "Therapy Goals"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: emergencyContactNameController,
          decoration: const InputDecoration(labelText: "Emergency Contact Name"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: emergencyContactPhoneController,
          decoration: const InputDecoration(labelText: "Emergency Contact Phone"),
          enabled: isEditing,
        ),
        TextFormField(
          controller: emergencyContactRelationController,
          decoration: const InputDecoration(labelText: "Emergency Contact Relation"),
          enabled: isEditing,
        ),
      ],
    );
  }
}