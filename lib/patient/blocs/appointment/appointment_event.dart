import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object> get props => [];
}

class FetchPatientAppointmentsEvent extends AppointmentEvent {
  final String patientId;

  const FetchPatientAppointmentsEvent({required this.patientId});

  @override
  List<Object> get props => [patientId];
}

class BookAppointmentEvent extends AppointmentEvent {
  final String patientId;
  final String specialistId;
  final DateTime startTime;
  final String message;

  const BookAppointmentEvent({
    required this.patientId,
    required this.specialistId,
    required this.startTime,
    required this.message,
  });

  @override
  List<Object> get props => [patientId, specialistId, startTime, message];
}