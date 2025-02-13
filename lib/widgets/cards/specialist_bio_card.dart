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
              color: Theme.of(context).colorScheme.primary, // Matches primary color
            ),
          ),
        ),
        Card(
          elevation: isDarkMode ? 2 : 4, // Less shadow in dark mode
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).cardColor, // Matches theme
          child: Container(
            // width: screenWidth * 0.9, // 90% of the screen width
            height: 300, // Fixed height for consistency
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
                    color: Theme.of(context).textTheme.bodyMedium?.color, // Adapts text color
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
