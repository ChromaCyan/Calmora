import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> userData;

  AuthSuccess({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OtpVerified extends AuthState {
  final Map<String, dynamic> verificationDetails;

  OtpVerified({required this.verificationDetails});

  @override
  List<Object?> get props => [verificationDetails];
}
