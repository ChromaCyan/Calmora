import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:armstrong/services/api.dart';

import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final ApiRepository _apiRepository;

  AppointmentBloc({required ApiRepository apiRepository})
      : _apiRepository = apiRepository,
        super(AppointmentInitial()) {
    on<BookAppointmentEvent>(_onBookAppointment);
  }

  Future<void> _onBookAppointment(
    BookAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      final appointment = await _apiRepository.createAppointment(
        event.patientId,
        event.specialistId,
        event.startTime,
        event.message,
      );
      emit(AppointmentBooked(appointment: appointment));
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
      final appointments = await _apiRepository.getPatientAppointments(event.patientId);
      emit(PatientAppointmentsLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }
}