import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:armstrong/authentication/blocs/auth_blocs.dart';
import 'package:armstrong/services/api.dart';

class AppProviders {
  static List<BlocProvider> getProviders() {
    final ApiRepository apiRepository = ApiRepository();

    return [
      // Authentication
      BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(apiRepository: apiRepository),  
      ),
    ];
  }
}
