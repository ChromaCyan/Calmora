import 'package:flutter/material.dart';
import 'splash_screen/screens/splash_screen.dart';
import 'login_screen_placeholder/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Armstrong',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      //home: const SplashScreen(),
      home: const LoginScreen(),
    );
  }
}
