import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class SpecialistsLoaded extends ProfileState {
  final List<dynamic> specialists;

  SpecialistsLoaded(this.specialists);

  @override
  List<Object?> get props => [specialists];
}

class SpecialistDetailsLoaded extends ProfileState {
  final Map<String, dynamic> specialistDetails;

  SpecialistDetailsLoaded(this.specialistDetails);

  @override
  List<Object?> get props => [specialistDetails];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
