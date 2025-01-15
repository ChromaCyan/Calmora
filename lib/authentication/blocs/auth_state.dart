abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final Map<String, dynamic> data;
  final String userType;

  AuthSuccessState({required this.data, required this.userType});
}

class AuthFailureState extends AuthState {
  final String error;

  AuthFailureState({required this.error});
}
