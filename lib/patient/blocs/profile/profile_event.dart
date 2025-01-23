import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchSpecialistsEvent extends ProfileEvent {}

class FetchSpecialistDetailsEvent extends ProfileEvent {
  final String specialistId;

  FetchSpecialistDetailsEvent(this.specialistId);

  @override
  List<Object?> get props => [specialistId];
}
