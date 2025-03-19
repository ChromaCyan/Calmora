import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:armstrong/services/api.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';
import 'package:intl/intl.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final ApiRepository _apiRepository;

  AppointmentBloc({required ApiRepository apiRepository})
      : _apiRepository = apiRepository,
        super(AppointmentInitial()) {
    on<FetchSpecialistAppointmentsEvent>(_onFetchSpecialistAppointments);
    on<FetchPatientAppointmentsEvent>(_onFetchPatientAppointments);
    on<AcceptAppointmentEvent>(_onAcceptAppointment);
    on<DeclineAppointmentEvent>(_onDeclineAppointment);
  }

  Future<void> _onFetchSpecialistAppointments(
    FetchSpecialistAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointments =
          await _apiRepository.getSpecialistAppointments(event.specialistId);
      emit(SpecialistAppointmentsLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onAcceptAppointment(
    AcceptAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointment =
          await _apiRepository.acceptAppointment(event.appointmentId);
      emit(AppointmentAccepted(appointment: appointment));
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onDeclineAppointment(
    DeclineAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointment =
          await _apiRepository.declineAppointment(event.appointmentId);
      emit(AppointmentDeclined(appointment: appointment));
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }

  Future<void> _onFetchPatientAppointments(
    FetchPatientAppointmentsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointments =
          await _apiRepository.getPatientAppointments(event.patientId);
      print('Appointments fetched: $appointments'); 
      emit(PatientAppointmentsLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }
}
