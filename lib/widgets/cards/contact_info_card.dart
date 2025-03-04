import 'package:flutter/material.dart';

class ContactInfoCard extends StatelessWidget {
  final String email;
  final String phoneNumber;

  const ContactInfoCard({Key? key, required this.email, required this.phoneNumber})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.email, email, theme.colorScheme.primary),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.phone, phoneNumber, theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor), // Uses primary color from theme
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
