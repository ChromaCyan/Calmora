abstract class AuthEvent {}

class RegisterUserEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String userType;
  final Map<String, dynamic> otherDetails;

  RegisterUserEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.userType,
    required this.otherDetails,
  });
}

class LoginUserEvent extends AuthEvent {
  final String email;
  final String password;
  final String userType;

  LoginUserEvent({
    required this.email,
    required this.password,
    required this.userType,
  });
}