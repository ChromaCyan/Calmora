import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/specialist_card.dart';
import 'package:armstrong/patient/screens/discover/specialist_detail_screen.dart';

class SpecialistListScreen extends StatelessWidget {
  SpecialistListScreen({Key? key}) : super(key: key);

  final List<Specialist> specialists = [
  Specialist(
    name: "Dr. Lulu",
    specialization: "Coach",
    imageUrl: "https://images.unsplash.com/photo-1566753323558-f4e0952af115?q=80&w=1921&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // Example image URL
  ),
  Specialist(
    name: "Dr. Bogart",
    specialization: "Psychiatrist",
    imageUrl: "https://images.unsplash.com/photo-1577880216142-8549e9488dad?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // Example image URL
  ),
  Specialist(
    name: "Dr. Moose",
    specialization: "Psychologist",
    imageUrl: "https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?q=80&w=1776&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // Example image URL
  ),
  // Add more specialists with image URLs...
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Specialist List")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: specialists.length,
          itemBuilder: (context, index) {
            return SpecialistCard(
              specialist: specialists[index],
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => SpecialistDetailScreen(specialist: specialists[index], specialistId: '',),
                //   ),
                // );
              },
            );
          },
        ),
      ),
    );
  }
}
