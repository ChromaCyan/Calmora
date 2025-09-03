import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:armstrong/services/api.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiRepository apiRepository;

  AuthBloc({required this.apiRepository}) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
    on<VerifyOtpEvent>(_onVerifyOtp);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userData = await apiRepository.registerUser(
        event.firstName,
        event.lastName,
        event.email,
        event.password,
        event.phoneNumber,
        event.gender,
        event.profileImage ?? "",
        event.otherDetails,
      );
      emit(AuthSuccess(userData: userData));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userData =
          await apiRepository.loginUser(event.email, event.password);
      print("Login successful: $userData");
      emit(AuthSuccess(userData: userData));
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(AuthError(message: errorMessage));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final verificationDetails =
          await apiRepository.verifyOTP(event.email, event.otp);
      emit(OtpVerified(verificationDetails: verificationDetails));
    } catch (e) {
      print("Login failed with error: $e");
      emit(AuthError(message: e.toString()));
    }
  }
}
