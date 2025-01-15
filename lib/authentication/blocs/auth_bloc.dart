import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:armstrong/services/api.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiRepository apiRepository;

  AuthBloc({required this.apiRepository}) : super(AuthInitial());

  @override
  Stream<AuthState> _mapRegisterUserEventToState(RegisterUserEvent event) async* {
  yield AuthLoadingState();
  try {
    final response = await apiRepository.registerUser(
      event.firstName,
      event.lastName,
      event.email,
      event.password,
      event.userType,
      event.otherDetails,
    );
    yield AuthSuccessState(data: response, userType: event.userType);
  } catch (e) {
    yield AuthFailureState(error: e.toString());
  }
}

Stream<AuthState> _mapLoginUserEventToState(LoginUserEvent event) async* {
  yield AuthLoadingState();
  try {
    final response = await apiRepository.loginUser(
      event.email,
      event.password,
      event.userType,
    );
    yield AuthSuccessState(data: response, userType: event.userType);
  } catch (e) {
    yield AuthFailureState(error: e.toString());
  }
}
}
