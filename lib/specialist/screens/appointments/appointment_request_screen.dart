import 'package:armstrong/config/colors.dart';
import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String name;
  final String specialty;
  final Color color;
  final String rating;
  final String location;
  final String time;
  final String date;

  const AppointmentDetailScreen({
    super.key,
    required this.name,
    required this.specialty,
    required this.color,
    required this.rating,
    required this.location,
    required this.time,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment"),
        backgroundColor: orangeContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You received an appointment for a consultation about: 'details stuff etc'",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut enim ad minim veniam, quis nostrud exercitation ullamco.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Patient",
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
                        children: [
                          const Icon(Icons.location_on,
                              size: 16.0, color: Colors.grey),
                          const SizedBox(width: 4.0),
                          Text(location),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 16.0, color: Colors.grey),
                          const SizedBox(width: 4.0),
                          Text(time),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16.0, color: Colors.grey),
                          const SizedBox(width: 4.0),
                          Text(date),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Appointment declined.")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Reject",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Appointment accepted.")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeContainer,
                    ),
                    child: Text(
                      "Accept",
                      style: TextStyle(color: Colors.black),
                    ),
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
