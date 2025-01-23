import 'package:flutter/material.dart';

class SpecialistDetailScreen extends StatelessWidget {

  const SpecialistDetailScreen({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final specialist = {
      'firstName': 'Jocelyn',
      'lastName': 'Bugarin',
      'specialization': 'Doctor',
      'profileImage': '', 
      'bio': 'No bio available.',
      'email': 'jocelynbugarin123@gmail.com',
      'phoneNumber': '123',
      'availability': 'Available',
    };

    final firstName = specialist['firstName'] ?? 'No first name available';
    final lastName = specialist['lastName'] ?? 'No last name available';
    final name = '$firstName $lastName';
    final specialization = specialist['specialization'] ?? 'Unknown';
    final bio = specialist['bio'] ?? 'No bio available.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Specialist Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              specialization,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              bio,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("Navigate to appointment booking screen");
                  },
                  child: const Text('Book Appointment'),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("Start chat with the specialist");
                  },
                  child: const Text('Chat with Specialist'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
