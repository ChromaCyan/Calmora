import 'package:flutter/material.dart';
import 'splash_screen/screens/splash_screen.dart';
import 'authentication/screens/login_screen.dart';
import 'package:armstrong/providers/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that shared_preferences is initialized before the app starts
  final prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(MyApp(isFirstLaunch: isFirstLaunch));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

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
        home: isFirstLaunch ? const SplashScreen() : const LoginScreen(),
      ),
    );
  }
}
