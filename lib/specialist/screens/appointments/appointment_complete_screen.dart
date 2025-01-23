import 'package:armstrong/config/colors.dart';
import 'package:flutter/material.dart';

class CompletedAppointmentDetail extends StatelessWidget {
  final String fullName;
  final String specialty;
  final String reason;
  final String phoneNumber;
  final String email;
  final String address;
  final String time;
  final String date;
  final String rating;

  const CompletedAppointmentDetail({
    Key? key,
    required this.fullName,
    required this.specialty,
    required this.reason,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.time,
    required this.date,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment"),
        backgroundColor: orangeContainer,
      ),
      body: SingleChildScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Full Name: $fullName",
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8.0),
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
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              "Rating",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 32.0,
                    color: index < double.parse(rating).round()
                        ? Colors.amber
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            Center(
              child: const Text(
                "5.0",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
