import 'package:armstrong/universal/blocs/appointment/appointment_new_bloc.dart';
import 'package:armstrong/patient/blocs/specialist_list/specialist_bloc.dart';
import 'package:armstrong/universal/blocs/appointment/appointment_bloc.dart';
import 'package:armstrong/universal/blocs/articles/article_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/services/api.dart';
import 'package:armstrong/services/gemini_api.dart';

class AppProviders {
  static List<BlocProvider> getProviders() {
    final ApiRepository apiRepository = ApiRepository();
    final ApiRepository2 apiRepository2 = ApiRepository2();

    return [
      // Authentication
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(apiRepository: apiRepository),
      ),
      // Profile
      BlocProvider<SpecialistBloc>(
        create: (context) => SpecialistBloc(apiRepository: apiRepository),
      ),
      //Appointment
      BlocProvider<AppointmentBloc>(
        create: (context) => AppointmentBloc(apiRepository: apiRepository),
      ),
      // Articles
      BlocProvider<ArticleBloc>(
        create: (context) => ArticleBloc(apiRepository: apiRepository),
      ),
      // Time Slot
      BlocProvider<TimeSlotBloc>(
        create: (context) => TimeSlotBloc(apiRepository: apiRepository),
      ),
    ];
  }
}
