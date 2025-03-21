import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/models/timeslot/timeslot.dart';

// ------- EVENTS -------
abstract class TimeSlotEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Create Time Slot
class CreateTimeSlotEvent extends TimeSlotEvent {
  final String specialistId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  CreateTimeSlotEvent({
    required this.specialistId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [specialistId, dayOfWeek, startTime, endTime];
}

// Update Time Slot
class UpdateTimeSlotEvent extends TimeSlotEvent {
  final String slotId;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String specialistId;

  UpdateTimeSlotEvent({
    required this.slotId,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    required this.specialistId,
  });

  @override
  List<Object?> get props => [slotId, dayOfWeek, startTime, endTime];
}

// Get Available Slots
class GetAvailableSlotsEvent extends TimeSlotEvent {
  final String specialistId;
  final DateTime date;

  GetAvailableSlotsEvent({
    required this.specialistId,
    required this.date,
  });

  @override
  List<Object?> get props => [specialistId, date];
}

// Book Appointment
class BookAppointmentEvent extends TimeSlotEvent {
  final String patientId;
  final String slotId;
  final String message;
  final DateTime appointmentDate;

  BookAppointmentEvent({
    required this.patientId,
    required this.slotId,
    required this.message,
    required this.appointmentDate,
  });

  @override
  List<Object?> get props => [patientId, slotId, message];
}

class GetAllSlotsEvent extends TimeSlotEvent {
  final String specialistId;

  GetAllSlotsEvent({required this.specialistId});

  @override
  List<Object?> get props => [specialistId];
}

// Delete Time Slot
class DeleteTimeSlotEvent extends TimeSlotEvent {
  final String slotId;
  final String specialistId;

  DeleteTimeSlotEvent({
    required this.slotId,
    required this.specialistId,
  });

  @override
  List<Object?> get props => [slotId, specialistId];
}

// ------- STATES -------
abstract class TimeSlotState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TimeSlotInitial extends TimeSlotState {}

class TimeSlotLoading extends TimeSlotState {}

class TimeSlotSuccess extends TimeSlotState {
  final dynamic data;
  TimeSlotSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class TimeSlotFailure extends TimeSlotState {
  final String error;
  TimeSlotFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ResetTimeSlotEvent extends TimeSlotEvent {}

class TimeSlotDeleted extends TimeSlotState {}

// ------- BLOC -------
class TimeSlotBloc extends Bloc<TimeSlotEvent, TimeSlotState> {
  final ApiRepository _apiRepository;

  TimeSlotBloc({required ApiRepository apiRepository})
      : _apiRepository = apiRepository,
        super(TimeSlotInitial()) {
    on<CreateTimeSlotEvent>(_onCreateTimeSlot);
    on<UpdateTimeSlotEvent>(_onUpdateTimeSlot);
    on<GetAvailableSlotsEvent>(_onGetAvailableSlots);
    on<BookAppointmentEvent>(_onBookAppointment);
    on<GetAllSlotsEvent>(_onGetAllSlots);
    on<ResetTimeSlotEvent>(_onResetTimeSlot);
    on<DeleteTimeSlotEvent>(_onDeleteTimeSlot);
  }

  // Get All Slots
  Future<void> _onGetAllSlots(
      GetAllSlotsEvent event, Emitter<TimeSlotState> emit) async {
    emit(TimeSlotLoading());
    try {
      final response = await _apiRepository.getAllTimeSlots(event.specialistId);

      if (response.isNotEmpty) {
        final slots = response
            .map<TimeSlotModel>((slot) => TimeSlotModel.fromJson(slot))
            .toList();
        emit(TimeSlotSuccess(data: slots));
      } else {
        throw Exception("No slots available for this specialist.");
      }
    } catch (error) {
      emit(TimeSlotFailure(error: error.toString()));
    }
  }

  // Create Time Slot
  Future<void> _onCreateTimeSlot(
      CreateTimeSlotEvent event, Emitter<TimeSlotState> emit) async {
    emit(TimeSlotLoading());
    try {
      final result = await _apiRepository.addTimeSlot(
        specialistId: event.specialistId,
        dayOfWeek: event.dayOfWeek,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      // Refetch all slots after adding
      final updatedSlots =
          await _apiRepository.getAllTimeSlots(event.specialistId);
      final slots = updatedSlots
          .map<TimeSlotModel>((slot) => TimeSlotModel.fromJson(slot))
          .toList();

      emit(TimeSlotSuccess(data: slots));
    } catch (error) {
      emit(TimeSlotFailure(error: error.toString()));
    }
  }

  // Update Time Slot
  Future<void> _onUpdateTimeSlot(
      UpdateTimeSlotEvent event, Emitter<TimeSlotState> emit) async {
    emit(TimeSlotLoading());
    try {
      final result = await _apiRepository.updateTimeSlot(
        slotId: event.slotId,
        dayOfWeek: event.dayOfWeek,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      // Refetch all slots after update
      final updatedSlots =
          await _apiRepository.getAllTimeSlots(event.specialistId);
      final slots = updatedSlots
          .map<TimeSlotModel>((slot) => TimeSlotModel.fromJson(slot))
          .toList();

      emit(TimeSlotSuccess(data: slots));
    } catch (error) {
      emit(TimeSlotFailure(error: error.toString()));
    }
  }

  // Get Available Slots
  Future<void> _onGetAvailableSlots(
      GetAvailableSlotsEvent event, Emitter<TimeSlotState> emit) async {
    emit(TimeSlotLoading());
    try {
      final slots = await _apiRepository.getAvailableTimeSlots(
        event.specialistId,
        event.date,
      );

      if (slots.isNotEmpty) {
        emit(TimeSlotSuccess(data: slots));
      } else {
        throw Exception("No slots available for the selected date.");
      }
    } catch (error) {
      emit(TimeSlotFailure(error: error.toString()));
    }
  }

  // Book Appointment
  Future<void> _onBookAppointment(
      BookAppointmentEvent event, Emitter<TimeSlotState> emit) async {
    emit(TimeSlotLoading());
    try {
      final result = await _apiRepository.bookAppointment(
        event.patientId,
        event.slotId,
        event.message,
        event.appointmentDate, 
      );
      emit(TimeSlotSuccess(data: result));
    } catch (error) {
      emit(TimeSlotFailure(error: error.toString()));
    }
  }

  Future<void> _onResetTimeSlot(
      ResetTimeSlotEvent event, Emitter<TimeSlotState> emit) async {
    emit(TimeSlotInitial());
  }

  // Delete Time Slot
  Future<void> _onDeleteTimeSlot(
      DeleteTimeSlotEvent event, Emitter<TimeSlotState> emit) async {
    try {
      final result = await _apiRepository.deleteTimeSlot(event.slotId);

      if (result['success']) {
        emit(TimeSlotDeleted());
      } else {
        throw Exception(result['message']);
      }
    } catch (error) {
      emit(TimeSlotFailure(error: error.toString()));
    }
  }
}
