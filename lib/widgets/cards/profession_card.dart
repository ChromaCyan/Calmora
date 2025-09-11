import 'package:flutter/material.dart';

class ProDeetsCard extends StatelessWidget {
  final int yearsOfExperience;
  final List languagesSpoken;
  final String licenseNumber;
  final String location;
  final String clinic;

  const ProDeetsCard({
    Key? key,
    required this.yearsOfExperience,
    required this.languagesSpoken,
    required this.licenseNumber,
    required this.location,
    required this.clinic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.work, 'Years of Experience: $yearsOfExperience', theme.colorScheme.primary),
        _buildInfoRow(Icons.language, 'Languages: ${languagesSpoken.join(", ")}', theme.colorScheme.primary),
        _buildInfoRow(Icons.assignment, 'License Number: $licenseNumber', theme.colorScheme.primary),
        _buildInfoRow(Icons.location_on, 'Location: $location', theme.colorScheme.primary),
        _buildInfoRow(Icons.local_hospital, 'Clinic: $clinic', theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
