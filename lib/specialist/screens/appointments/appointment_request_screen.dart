import 'package:armstrong/config/colors.dart';
import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String fullName;
  final String specialty;
  final String reason;
  final String phoneNumber;
  final String email;
  final String address;
  final String time;
  final String date;

  const AppointmentDetailScreen({
    super.key,
    required this.fullName,
    required this.specialty,
    required this.reason,
    required this.phoneNumber,
    required this.email,
    required this.address,
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
                "You received an appointment for a consultation:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                "Below are the details provided by the patient:",
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.person,
                            size: 48.0,
                            color: orangeContainer,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Specialty: $specialty",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Reason for Appointment: $reason",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Phone Number: $phoneNumber",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Email: $email",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Address: $address",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Date: $date",
                            style: const TextStyle(fontSize: 14.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Time: $time",
                            style: const TextStyle(fontSize: 14.0),
                          ),
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
                    child: const Text(
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
                    child: const Text(
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