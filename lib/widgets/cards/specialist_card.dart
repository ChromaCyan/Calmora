import 'package:flutter/material.dart';

class Specialist {
  final String name;
  final String specialization;
  final String imageUrl;
  final String location; // Added location field

  Specialist({
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.location, // Required location
  });
}

class SpecialistCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;

  const SpecialistCard({Key? key, required this.specialist, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double padding = screenWidth > 600 ? 16.0 : 12.0;
    double nameFontSize = screenWidth > 600 ? 18.0 : 16.0;
    double specializationFontSize = screenWidth > 600 ? 14.0 : 12.0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  specialist.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                specialist.name,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                specialist.specialization,
                style: TextStyle(
                  fontSize: specializationFontSize,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Location with Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    specialist.location,
                    style: TextStyle(
                      fontSize: specializationFontSize,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
