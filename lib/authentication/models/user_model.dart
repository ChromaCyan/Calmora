class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? profileImage;
  final String? phoneNumber;
  final String userType;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.profileImage,
    this.phoneNumber,
    required this.userType,
  });

  // Factory constructor to parse JSON into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    if (json['userType'] == 'patient') {
      return Patient.fromJson(json);
    } else if (json['userType'] == 'specialist') {
      return Specialist.fromJson(json);
    } else {
      return User(
        id: json['_id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password'],
        profileImage: json['profileImage'],
        phoneNumber: json['phoneNumber'],
        userType: json['userType'],
      );
    }
  }

  // Convert a User object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'profileImage': profileImage,
      'phoneNumber': phoneNumber,
      'userType': userType,
    };
  }
}

class Patient extends User {
  final String? address;
  final DateTime dateOfBirth;
  final EmergencyContact? emergencyContact;
  final String? medicalHistory;
  final List<String>? therapyGoals;

  Patient({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? profileImage,
    required String phoneNumber,
    required String userType,
    this.address,
    required this.dateOfBirth,
    this.emergencyContact,
    this.medicalHistory,
    this.therapyGoals, 
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          profileImage: profileImage,
          phoneNumber: phoneNumber,
          userType: userType,
        );

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
      userType: json['userType'],
      address: json['address'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      emergencyContact: json['emergencyContact'] != null 
          ? EmergencyContact.fromJson(json['emergencyContact']) 
          : null, 
      medicalHistory: json['medicalHistory'],
      therapyGoals: json['therapyGoals'] != null 
          ? List<String>.from(json['therapyGoals']) 
          : null, // optional
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'emergencyContact': emergencyContact?.toJson(), 
      'medicalHistory': medicalHistory,
      'therapyGoals': therapyGoals ?? [], 
    });
    return data;
  }
}

class EmergencyContact {
  final String? name;
  final String? phone;
  final String? relation;

  EmergencyContact({
    this.name,
    this.phone,
    this.relation,
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

class Specialist extends User {
  final String specialization;
  final String licenseNumber;

  Specialist({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? profileImage,
    required String phoneNumber,
    required String userType,
    required this.specialization,
    required this.licenseNumber,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          profileImage: profileImage,
          phoneNumber: phoneNumber,
          userType: userType,
        );

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      profileImage: json['profileImage'],
      phoneNumber: json['phoneNumber'],
      userType: json['userType'],
      specialization: json['specialization'],
      licenseNumber: json['licenseNumber'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'specialization': specialization,
      'licenseNumber': licenseNumber,
    });
    return data;
  }
}
