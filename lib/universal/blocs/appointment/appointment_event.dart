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

class FetchSpecialistAppointmentsEvent extends AppointmentEvent {
  final String specialistId;

  const FetchSpecialistAppointmentsEvent({required this.specialistId});

  @override
  List<Object> get props => [specialistId];
}

class FetchAvailableTimeSlotsEvent extends AppointmentEvent {
  final String specialistId;
  final DateTime date;

  const FetchAvailableTimeSlotsEvent({required this.specialistId, required this.date});

  @override
  List<Object> get props => [specialistId];
}

class AcceptAppointmentEvent extends AppointmentEvent {
  final String appointmentId;

  const AcceptAppointmentEvent({required this.appointmentId});

  @override
  List<Object> get props => [appointmentId];
}

class DeclineAppointmentEvent extends AppointmentEvent {
  final String appointmentId;

  const DeclineAppointmentEvent({required this.appointmentId});

  @override
  List<Object> get props => [appointmentId];
}