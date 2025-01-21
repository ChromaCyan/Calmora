class Specialist {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? profileImage;
  final String specialization;
  final String licenseNumber;
  final String phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userType; 

  Specialist({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.profileImage,
    required this.specialization,
    required this.licenseNumber,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.userType,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      profileImage: json['profileImage'],
      specialization: json['specialization'],
      licenseNumber: json['licenseNumber'],
      phoneNumber: json['phoneNumber'],
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
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userType': userType, 
    };
  }
}
