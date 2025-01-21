class Patient {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? profileImage;
  final String? address;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final EmergencyContact emergencyContact;
  final String? medicalHistory;
  final List<String> therapyGoals;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userType; 

  Patient({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.profileImage,
    this.address,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.emergencyContact,
    this.medicalHistory,
    this.therapyGoals = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.userType, 
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      profileImage: json['profileImage'],
      address: json['address'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      phoneNumber: json['phoneNumber'],
      emergencyContact: EmergencyContact.fromJson(json['emergencyContact']),
      medicalHistory: json['medicalHistory'],
      therapyGoals: List<String>.from(json['therapyGoals']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userType: json['userType'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'profileImage': profileImage,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phoneNumber': phoneNumber,
      'emergencyContact': emergencyContact.toJson(),
      'medicalHistory': medicalHistory,
      'therapyGoals': therapyGoals,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userType': userType, 
    };
  }
}


class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
  });

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
