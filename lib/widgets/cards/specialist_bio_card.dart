import 'package:flutter/material.dart';

class SpecialistBioSection extends StatelessWidget {
  final String bio;

  const SpecialistBioSection({Key? key, required this.bio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark; // Detect theme

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Bio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary, 
            ),
          ),
        ),
        Card(
          elevation: isDarkMode ? 2 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).cardColor, 
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  bio.isNotEmpty ? bio : "No bio available.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Theme.of(context).textTheme.bodyMedium?.color, 
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
