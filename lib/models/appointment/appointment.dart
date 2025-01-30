import 'dart:convert';

class Appointment {
  final String id;
  final String patientId;
  final String specialistId;
  final DateTime startTime;
  final String message;
  final String status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.specialistId,
    required this.startTime,
    required this.message,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'],
      patientId: json['patientId'],
      specialistId: json['specialistId'],
      startTime: DateTime.parse(json['startTime']),
      message: json['message'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'patientId': patientId,
      'specialistId': specialistId,
      'startTime': startTime.toIso8601String(),
      'message': message,
      'status': status,
    };
  }
}
