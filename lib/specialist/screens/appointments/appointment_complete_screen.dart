import 'package:armstrong/config/colors.dart';
import 'package:flutter/material.dart';

class CompletedAppointmentDetail extends StatelessWidget {
  final String name;
  final String specialty;
  final Color color;
  final String rating;
  final String date;
  final String location;

  const CompletedAppointmentDetail({
    Key? key,
    required this.name,
    required this.specialty,
    required this.color,
    required this.rating,
    required this.date,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment"),
        backgroundColor: orangeContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appointment Details",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              "Here are the details of your completed appointment.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Patient Information",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8.0),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  radius: 30.0,
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      specialty,
                      style: const TextStyle(color: orangeContainer),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          size: 16.0,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    Text(rating),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              "Appointment Details",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8.0),
                Text(date),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8.0),
                Text(location),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
