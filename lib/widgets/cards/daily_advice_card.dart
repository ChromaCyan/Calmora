import 'package:flutter/material.dart';

class HealthAdviceSection extends StatelessWidget {
  const HealthAdviceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Mental Health Advice',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Take breaks, practice self-care, and reach out when you need support.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}