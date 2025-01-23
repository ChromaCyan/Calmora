// profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:armstrong/services/api.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiRepository apiRepository;

  ProfileBloc({required this.apiRepository}) : super(ProfileInitial()) {
    on<FetchSpecialistsEvent>(_onFetchSpecialists);
    on<FetchSpecialistDetailsEvent>(_onFetchSpecialistDetails);
  }

  Future<void> _onFetchSpecialists(
    FetchSpecialistsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final specialists = await apiRepository.getSpecialistList();
      emit(SpecialistsLoaded(specialists));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchSpecialistDetails(
    FetchSpecialistDetailsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final specialistDetails = await apiRepository.getProfile();
      emit(SpecialistDetailsLoaded(specialistDetails));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
