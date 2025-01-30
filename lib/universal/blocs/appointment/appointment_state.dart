import 'package:equatable/equatable.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentBooked extends AppointmentState {
  final Map<String, dynamic> appointment;

  const AppointmentBooked({required this.appointment});

  @override
  List<Object> get props => [appointment];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({required this.message});

  @override
  List<Object> get props => [message];
}

class PatientAppointmentsLoaded extends AppointmentState {
  final List<dynamic> appointments;

  const PatientAppointmentsLoaded({required this.appointments});

  @override
  List<Object> get props => [appointments];
}

class SpecialistAppointmentsLoaded extends AppointmentState {
  final List<dynamic> appointments;

  const SpecialistAppointmentsLoaded({required this.appointments});

  @override
  List<Object> get props => [appointments];
}

class AppointmentAccepted extends AppointmentState {
  final Map<String, dynamic> appointment;

  const AppointmentAccepted({required this.appointment});

  @override
  List<Object> get props => [appointment];
}

class AppointmentDeclined extends AppointmentState {
  final Map<String, dynamic> appointment;

  const AppointmentDeclined({required this.appointment});

  @override
  List<Object> get props => [appointment];
}
