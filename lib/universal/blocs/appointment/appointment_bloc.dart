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
    on<BookAppointmentEvent>(_onBookAppointment);
    on<FetchSpecialistAppointmentsEvent>(_onFetchSpecialistAppointments);
    on<FetchPatientAppointmentsEvent>(_onFetchPatientAppointments);
    on<AcceptAppointmentEvent>(_onAcceptAppointment);
    on<DeclineAppointmentEvent>(_onDeclineAppointment);
    on<FetchAvailableTimeSlotsEvent>(_onFetchAvailableTimeSlots);
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

  Future<void> _onBookAppointment(
    BookAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(AppointmentLoading());
    try {
      // Fetch updated available slots
      final List<DateTime> availableSlots = await _apiRepository
          .fetchAvailableTimeSlots(event.specialistId, event.startTime);

      // Check if the selected time is available
      bool isSlotAvailable = availableSlots.any(
        (slot) => slot.isAtSameMomentAs(event.startTime),
      );

      if (!isSlotAvailable) {
        emit(AppointmentError(message: "Selected time slot is not available"));
        return;
      }

      // Create the appointment
      final appointment = await _apiRepository.addAppointment(
        event.patientId,
        event.specialistId,
        event.startTime,
        event.message,
      );

      // After booking, refresh available time slots
      final List<DateTime> updatedSlots = await _apiRepository
          .fetchAvailableTimeSlots(event.specialistId, event.startTime);

      emit(AvailableTimeSlotsLoaded(availableSlots: updatedSlots));
      emit(AppointmentBooked(appointment: appointment));
    } catch (e) {
      if (e.toString().contains(
          "You already have an active appointment with this specialist")) {
        emit(AppointmentError(
            message:
                "You already have an active appointment with this specialist"));
      } else {
        emit(AppointmentError(message: e.toString()));
      }
    }
  }

  Future<void> _onFetchAvailableTimeSlots(
    FetchAvailableTimeSlotsEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      // Fetch available slots as a simple List<DateTime>
      final List<DateTime> availableSlots = await _apiRepository
          .fetchAvailableTimeSlots(event.specialistId, event.date);

      emit(AvailableTimeSlotsLoaded(availableSlots: availableSlots));
    } catch (e) {
      if (e.toString().contains("Working hours not set")) {
        emit(AppointmentError(
            message: "Specialist's working hours are not set"));
      } else {
        emit(AppointmentError(
            message: "Failed to fetch available slots: ${e.toString()}"));
      }
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
      emit(PatientAppointmentsLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError(message: e.toString()));
    }
  }
}
