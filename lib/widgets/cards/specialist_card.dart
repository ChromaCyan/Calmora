import 'package:flutter/material.dart';

class Specialist {
  final String name;
  final String specialization;
  final String imageUrl; // Add an image URL field

  Specialist({required this.name, required this.specialization, required this.imageUrl});
}

class SpecialistCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;

  const SpecialistCard({Key? key, required this.specialist, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the screen width to adjust padding and font size
    double screenWidth = MediaQuery.of(context).size.width;

    // Define padding and font size based on screen size
    double padding = screenWidth > 600 ? 16.0 : 12.0; // More padding for wide screens
    double nameFontSize = screenWidth > 600 ? 18.0 : 16.0; // Larger font size for wide screens
    double specializationFontSize = screenWidth > 600 ? 14.0 : 12.0; // Smaller font for narrow screens

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Image at the top
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  specialist.imageUrl, // Add image URL
                  height: 120, // Set a fixed height for the image
                  width: double.infinity, // Make the image take up the full width
                  fit: BoxFit.cover, // Ensure the image covers the space
                ),
              ),
              SizedBox(height: 10), // Space between the image and text
              // Name text
              Text(
                specialist.name,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8), // Space between the name and specialization text
              // Specialization text
              Text(
                specialist.specialization,
                style: TextStyle(
                  fontSize: specializationFontSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
