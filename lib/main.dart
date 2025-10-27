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
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:armstrong/config/global_loader.dart';
import 'services/socket_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  await SupabaseService.initialize();

  // Initialize Local Notifications
  await NotificationService.initNotifications();

  String? token = await storage.read(key: 'jwt');
  String? role;
  bool onboardingCompleted = await _checkOnboardingStatus();

  bool hasCompletedSurvey = false;
  bool surveyOnboardingCompleted = false;

  // Get the notification that opened the app
  final NotificationAppLaunchDetails? notificationLaunchDetails =
      await NotificationService.flutterLocalNotifications
          .getNotificationAppLaunchDetails();

  Map<String, dynamic>? initialPayload;
  if (notificationLaunchDetails?.didNotificationLaunchApp ?? false) {
    if (notificationLaunchDetails!.notificationResponse?.payload != null) {
      initialPayload = Map<String, dynamic>.from(
          jsonDecode(notificationLaunchDetails.notificationResponse!.payload!));
    }
  }

  if (token != null) {
    try {
      final jwt = JWT.verify(token, SecretKey('your_jwt_secret_key'));
      role = jwt.payload['userType'];
      final userId = jwt.payload['userId'];
      final hasCompletedSurveyFromJWT = jwt.payload['surveyCompleted'] ?? false;

      if (token != null && role == 'Patient') {
        hasCompletedSurvey = hasCompletedSurveyFromJWT;
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

  // Setup EasyLoading globally
  _setupEasyLoading();

  SocketService().navigatorKey = navigatorKey;

  runApp(MyApp(
    initialNotificationPayload: initialPayload,
    isLoggedIn: token != null,
    role: role,
    onboardingCompleted: onboardingCompleted,
    hasCompletedSurvey: hasCompletedSurvey,
    surveyOnboardingCompleted: surveyOnboardingCompleted,
  ));
}

// Setup EasyLoading globally
void _setupEasyLoading() {
  EasyLoading.instance
    ..indicatorWidget = GlobalLoader.loader // your custom loader
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
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
  final Map<String, dynamic>? initialNotificationPayload; 

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.role,
    required this.onboardingCompleted,
    required this.hasCompletedSurvey,
    required this.surveyOnboardingCompleted,
    this.initialNotificationPayload,
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
            navigatorKey: navigatorKey,
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
            builder: EasyLoading.init(), // attach EasyLoading globally
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
      return hasCompletedSurvey
          ? const PatientHomeScreen()
          : const SurveyScreen();
    } else if (role == 'Specialist') {
      return const SpecialistHomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
