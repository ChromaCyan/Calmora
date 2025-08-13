import 'package:armstrong/config/app_theme.dart';
import 'package:armstrong/providers/provider.dart';
import 'package:provider/provider.dart';
import 'package:armstrong/splash_screen/screens/survey_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'splash_screen/screens/splash_screen.dart';
import 'authentication/screens/login_screen.dart';
import 'package:armstrong/patient/screens/patient_nav_home_screen.dart';
import 'package:armstrong/specialist/screens/specialist_nav_home_screen.dart';
import 'package:armstrong/providers/font_provider.dart';
import 'package:armstrong/providers/theme_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:armstrong/services/notification_service.dart';
import 'dart:async';
import 'services/supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  await SupabaseService.initialize();

  print("🚀 Starting app...");

  // Initialize Local Notifications
  await NotificationService.initNotifications();

  Future.delayed(Duration(seconds: 3), () {
    // socketService.showNotification(
    //     "Welcome to Armstrong", "Men's Mental Health App!");
  });

  String? token = await storage.read(key: 'jwt');
  String? role;
  bool onboardingCompleted = await _checkOnboardingStatus();

  // Check if survey is completed for patient
  bool hasCompletedSurvey = false;
  bool surveyOnboardingCompleted = false;

  if (token != null) {
    try {
      final jwt = JWT.verify(token, SecretKey('your_jwt_secret_key'));
      role = jwt.payload['userType'];
      final userId = jwt.payload['userId'];

      if (token != null && role == 'Patient') {
        hasCompletedSurvey =
            await storage.read(key: 'hasCompletedSurvey_$userId') == 'true';
        surveyOnboardingCompleted =
            await storage.read(key: 'survey_onboarding_completed_$userId') ==
                'true';
      }
    } catch (e) {
      print('Invalid token: $e');
      await storage.delete(key: 'jwt');
      token = null;
      role = null;
    }
  }

  // Disabling the socket connection )(Temporary because of vercel is serverless)
  // if (token != null) {
  //   socketService.connect(token);  // Commented out
  // }

  runApp(MyApp(
    isLoggedIn: token != null,
    role: role,
    onboardingCompleted: onboardingCompleted,
    hasCompletedSurvey: hasCompletedSurvey,
    surveyOnboardingCompleted: surveyOnboardingCompleted,
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
  final bool hasCompletedSurvey;
  final bool surveyOnboardingCompleted;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.role,
    required this.onboardingCompleted,
    required this.hasCompletedSurvey,
    required this.surveyOnboardingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          ...AppProviders.getProviders(),
        ],
        child: ShowCaseWidget(
          builder: (context) => MaterialApp(
            title: 'Armstrong',
            theme: AppTheme.light.copyWith(
              textTheme: AppTheme.light.textTheme.apply(
                fontFamily: context.watch<FontProvider>().selectedFont,
              ),
            ),
            darkTheme: AppTheme.dark.copyWith(
              textTheme: AppTheme.dark.textTheme.apply(
                fontFamily: context.watch<FontProvider>().selectedFont,
              ),
            ),
            themeMode: context.watch<ThemeProvider>().themeMode,
            debugShowCheckedModeBanner: false,
            home: onboardingCompleted
                ? _getInitialScreen()
                : const SplashScreen(),
          ),
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
      // Check if the patient has completed the survey and onboarding before navigating to home screen
      if (hasCompletedSurvey && surveyOnboardingCompleted) {
        return const PatientHomeScreen();
      } else {
        // Navigate to Survey if the user hasn't completed it
        return const SurveyScreen();
      }
    } else if (role == 'Specialist') {
      // Navigate to Specialist home screen
      return const SpecialistHomeScreen();
    } else {
      // Default case, navigate to Login screen if no valid role
      return const LoginScreen();
    }
  }
}
