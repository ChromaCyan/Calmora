import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/patient/blocs/profile/profile_bloc.dart';
import 'package:armstrong/services/api.dart';

class AppProviders {
  static List<BlocProvider> getProviders() {
    final ApiRepository apiRepository = ApiRepository();

    return [
      // Authentication
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(apiRepository: apiRepository),
      ),
      // Profile
      BlocProvider<ProfileBloc>(
        create: (context) => ProfileBloc(apiRepository: apiRepository),
      ),
      // Appointment
      BlocProvider<AppointmentBloc>(
        create: (context) => AppointmentBloc(apiRepository: apiRepository),
      ),
    ];
  }
}
