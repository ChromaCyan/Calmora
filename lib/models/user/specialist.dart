import 'dart:convert';

class Specialist {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String phoneNumber;
  final String? profileImage;
  final String specialization;
  final String? licenseNumber;
  final String? bio;
  final int? yearsOfExperience;
  final List<String>? languagesSpoken;
  final String? availability;
  final String? workingHoursStart;
  final String? workingHoursEnd;
  final String? location;
  final String? clinic;

  Specialist({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.phoneNumber,
    this.profileImage,
    required this.specialization,
    this.licenseNumber,
    this.bio,
    this.yearsOfExperience,
    this.languagesSpoken,
    this.availability,
    this.workingHoursStart,
    this.workingHoursEnd,
    this.location,
    this.clinic,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      gender: json['gender'] ?? 'unknown',
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      specialization: json['specialization'] ?? 'Unknown',
      licenseNumber: json['licenseNumber'],
      bio: json['bio'],
      yearsOfExperience: json['yearsOfExperience'],
      languagesSpoken: json['languagesSpoken'] != null
          ? List<String>.from(json['languagesSpoken'])
          : null,
      availability: json['availability'],
      workingHoursStart: json['workingHours']?['start'],
      workingHoursEnd: json['workingHours']?['end'],
      location: json['location'],
      clinic: json['clinic'],
    );
  }
}
