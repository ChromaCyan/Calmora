import 'package:flutter/material.dart';

class CommonFieldsWidget extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController dateOfBirthController;
  final bool isEditing;
  final VoidCallback onPickDateOfBirth;

  const CommonFieldsWidget({
    Key? key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.dateOfBirthController,
    required this.isEditing,
    required this.onPickDateOfBirth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current theme (light or dark)
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView( // Add this widget to allow scrolling
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          // Adjust container background color based on the theme
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
            // First Name Field
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: "First Name",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blueGrey),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: isEditing,
            ),
            const SizedBox(height: 16),

            // Last Name Field
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: "Last Name",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blueGrey),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: isEditing,
            ),
            const SizedBox(height: 16),

            // Phone Number Field
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blueGrey),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: isEditing,
            ),
            const SizedBox(height: 16),

            // Date of Birth Field
            TextField(
              controller: dateOfBirthController,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blueGrey),
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              readOnly: true,
              onTap: isEditing ? onPickDateOfBirth : null,
            ),
          ],
        ),
      ),
    );
  }
}
