import 'dart:convert';

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String? profileImage;
  final String userType;
  
  // Patient-specific fields
  final String? address;
  final DateTime? dateOfBirth;
  final EmergencyContact? emergencyContact;
  final String? medicalHistory;
  final List<String>? therapyGoals;

  // Specialist-specific fields
  final String? specialization;
  final String? licenseNumber;
  final String? bio;
  final int? yearsOfExperience;
  final List<String>? languagesSpoken;
  final String? availability;
  final String? workingHoursStart;
  final String? workingHoursEnd;
  final String? location;
  final String? clinic;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.profileImage,
    required this.userType,
    this.address,
    this.dateOfBirth,
    this.emergencyContact,
    this.medicalHistory,
    this.therapyGoals,
    this.specialization,
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

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      profileImage: json['profileImage'],
      userType: json['userType'],
      
      // Patient fields
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      emergencyContact: json['emergencyContact'] != null ? EmergencyContact.fromJson(json['emergencyContact']) : null,
      medicalHistory: json['medicalHistory'],
      therapyGoals: json['therapyGoals'] != null ? List<String>.from(json['therapyGoals']) : null,

      // Specialist fields
      specialization: json['specialization'],
      licenseNumber: json['licenseNumber'],
      bio: json['bio'],
      yearsOfExperience: json['yearsOfExperience'],
      languagesSpoken: json['languagesSpoken'] != null ? List<String>.from(json['languagesSpoken']) : null,
      availability: json['availability'],
      workingHoursStart: json['workingHours']?['start'],
      workingHoursEnd: json['workingHours']?['end'],
      location: json['location'],
      clinic: json['clinic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'profileImage': profileImage,
      'userType': userType,

      // Patient fields
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'emergencyContact': emergencyContact?.toJson(),
      'medicalHistory': medicalHistory,
      'therapyGoals': therapyGoals,

      // Specialist fields
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'languagesSpoken': languagesSpoken,
      'availability': availability,
      'workingHours': {
        'start': workingHoursStart,
        'end': workingHoursEnd,
      },
      'location': location,
      'clinic': clinic,
    };
  }
}

class EmergencyContact {
  final String? name;
  final String? phone;
  final String? relation;

  EmergencyContact({this.name, this.phone, this.relation});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phone: json['phone'],
      relation: json['relation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
    };
  }
}
