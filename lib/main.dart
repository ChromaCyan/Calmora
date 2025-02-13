import 'package:armstrong/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'splash_screen/screens/splash_screen.dart';
import 'authentication/screens/login_screen.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/providers/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:armstrong/services/socket_service.dart';
import 'package:armstrong/services/notification_service.dart';
import 'dart:async';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'services/supabase.dart';
import 'package:flutter/services.dart'; // Import the necessary package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  final socketService = SocketService();
  await SupabaseService.initialize();

  print("🚀 Starting app...");

  // Initialize Local Notifications
  await NotificationService.initNotifications();

  Future.delayed(Duration(seconds: 3), () {
    socketService.showNotification("Welcome to Armstrong", "Men's Mental Health App!");
  });

  String? token = await storage.read(key: 'jwt');
  String? role;
  bool onboardingCompleted = await _checkOnboardingStatus();

  if (token != null) {
    try {
      final jwt = JWT.verify(token, SecretKey('your_jwt_secret_key'));
      role = jwt.payload['userType'];
    } catch (e) {
      print('Invalid token: $e');
      await storage.delete(key: 'jwt');
      token = null;
      role = null;
    }
  }

  // Connect to Socket if Logged In
  if (token != null) {
    socketService.connect(token);
  }

  runApp(MyApp(
    isLoggedIn: token != null,
    role: role,
    onboardingCompleted: onboardingCompleted,
  ));
}

Future<bool> _checkOnboardingStatus() async {
  final storage = FlutterSecureStorage();
  String? completed = await storage.read(key: 'onboarding_completed');
  return completed == 'true';
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? role;
  final bool onboardingCompleted;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.role,
    required this.onboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppProviders.getProviders(),
      child: ShowCaseWidget(
        builder: (context) => MaterialApp(
          title: 'Armstrong',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: onboardingCompleted ? _getInitialScreen() : const SplashScreen(),
        ),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (!isLoggedIn) {
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
