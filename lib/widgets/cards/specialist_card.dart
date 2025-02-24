import 'package:flutter/material.dart';

class Specialist {
  final String name;
  final String specialization;
  final String imageUrl;
  final String location;

  Specialist({
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.location,
  });
}

class SpecialistCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;

  const SpecialistCard({Key? key, required this.specialist, required this.onTap}) : super(key: key);

  // Function to format the name (show only first word, max 7 chars)
  String formatName(String name) {
    List<String> words = name.split(" ");
    String firstWord = words.isNotEmpty ? words[0] : "";
    return firstWord.length > 7 ? "${firstWord.substring(0, 7)}..." : firstWord;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Responsive font sizes
    double nameFontSize = screenWidth * 0.045;
    double specializationFontSize = screenWidth * 0.035;
    double locationFontSize = screenWidth * 0.032;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 180, // Ensures cards don't become too small
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Flexible height
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image (Responsive size)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 4 / 3, // Keeps the image's ratio constant
                    child: Image.network(
                      specialist.imageUrl,
                      fit: BoxFit.cover, // Fills the space while maintaining proportion
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Name (Formatted to show only the first word, max 7 chars)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    formatName(specialist.name),
                    style: TextStyle(
                      fontSize: nameFontSize.clamp(16, 22),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),

                // Specialization (Now properly truncated with ...)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    specialist.specialization,
                    style: TextStyle(
                      fontSize: specializationFontSize.clamp(14, 18),
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, // Forces text to a single line
                    overflow: TextOverflow.ellipsis, // Adds "..." when overflowing
                  ),
                ),
                const SizedBox(height: 6),

                // Location with Icon (Flexible Layout, no truncation)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 18),
                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        specialist.location,
                        style: TextStyle(
                          fontSize: locationFontSize.clamp(12, 16),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2, // Allows wrapping instead of truncation
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
