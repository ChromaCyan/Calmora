import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/models/user/specialist.dart';
import 'package:armstrong/services/api.dart';

//=================================================================================================
// EVENT BLOC LINES
abstract class SpecialistEvent {}

class FetchSpecialists extends SpecialistEvent {}

class FetchSpecialistDetails extends SpecialistEvent {
  final String specialistId;
  FetchSpecialistDetails(this.specialistId);
}

//=================================================================================================
// STATE BLOC LINES

abstract class SpecialistState {}

class SpecialistInitial extends SpecialistState {}

class SpecialistLoading extends SpecialistState {}

class SpecialistLoaded extends SpecialistState {
  final List<Specialist> specialists;
  SpecialistLoaded(this.specialists);
}

class SpecialistDetailLoaded extends SpecialistState {
  final Specialist specialist;
  SpecialistDetailLoaded(this.specialist);
}

class SpecialistError extends SpecialistState {
  final String message;
  SpecialistError(this.message);
}

//=================================================================================================
// BLOCS LINES

class SpecialistBloc extends Bloc<SpecialistEvent, SpecialistState> {
  final ApiRepository _apiRepository;

  SpecialistBloc({required ApiRepository apiRepository})
      : _apiRepository = apiRepository,
        super(SpecialistInitial()) {
    on<FetchSpecialists>(_onFetchSpecialists);
    on<FetchSpecialistDetails>(_onFetchSpecialistDetails);
  }

  Future<void> _onFetchSpecialists(
      FetchSpecialists event, Emitter<SpecialistState> emit) async {
    emit(SpecialistLoading());
    try {
      final specialists = await _apiRepository.fetchSpecialists();
      emit(SpecialistLoaded(specialists));
    } catch (e) {
      emit(SpecialistError(e.toString()));
    }
  }

  Future<void> _onFetchSpecialistDetails(
      FetchSpecialistDetails event, Emitter<SpecialistState> emit) async {
    emit(SpecialistLoading());
    try {
      final specialist = await _apiRepository.fetchSpecialistById(event.specialistId);
      emit(SpecialistDetailLoaded(specialist));
    } catch (e) {
      emit(SpecialistError(e.toString()));
    }
  }
}