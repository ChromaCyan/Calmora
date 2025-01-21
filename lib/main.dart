import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'splash_screen/screens/splash_screen.dart';
import 'authentication/screens/login_screen.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/providers/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();

  String? onboardingCompleted = await storage.read(key: 'onboarding_completed');
  bool hasCompletedOnboarding = onboardingCompleted == 'true';

  String? token = await storage.read(key: 'jwt');
  String? role;

  if (token != null) {
    try {
      final jwt = JWT.verify(token, SecretKey('123_123'));
      role = jwt.payload['userType']; 
    } catch (e) {
      print('Invalid token: $e');
      role = null;
    }
  }

  runApp(MyApp(
    hasCompletedOnboarding: hasCompletedOnboarding,
    isLoggedIn: token != null,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  final bool isLoggedIn;
  final String? role;

  const MyApp({
    super.key,
    required this.hasCompletedOnboarding,
    required this.isLoggedIn,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppProviders.getProviders(),
      child: MaterialApp(
        title: 'Armstrong',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: _getInitialScreen(),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (!hasCompletedOnboarding) {
      return const SplashScreen();
    } else if (!isLoggedIn) {
      return const LoginScreen();
    } else {
      return _getHomeScreen(role);
    }
  }

  Widget _getHomeScreen(String? role) {
    if (role == 'Patient') {
      return const PatientHomeScreen();
    } else if (role == 'Specialist') {
      return const SpecialistHomeScreen();
    } else {
      return const LoginScreen(); 
    }
  }
}
