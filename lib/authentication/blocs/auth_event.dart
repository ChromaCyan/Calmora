import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RegisterEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String gender;
  final String? profileImage;
  final String otp; 
  final Map<String, dynamic> otherDetails;

  RegisterEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.gender,
    this.profileImage,
    required this.otp, 
    required this.otherDetails,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        password,
        phoneNumber,
        gender,
        profileImage,
        otp,
        otherDetails,
      ];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class SendVerificationOtpEvent extends AuthEvent {
  final String email;

  SendVerificationOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}
