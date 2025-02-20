import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:armstrong/splash_screen/models/splash_message.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  bool onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  // Function to check if onboarding is completed
  Future<void> _checkOnboardingStatus() async {
    final storage = FlutterSecureStorage();
    String? completed = await storage.read(key: 'onboarding_completed');
    if (completed == 'true') {
      setState(() {
        onboardingCompleted = true;
      });
      // Skip onboarding and navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (onboardingCompleted) {
      return Container();
    }

    Size size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Use the app's background color or primary color instead of an image
          Positioned.fill(
            child: Container(
              color:
                  colorScheme.background, // Using background color from theme
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.7,
                child: PageView.builder(
                  itemCount: onBoardData.length,
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return onBoardingItems(size, index, context);
                  },
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (currentPage == onBoardData.length - 1) {
                    final storage = FlutterSecureStorage();
                    // Mark onboarding as complete
                    await storage.write(
                        key: 'onboarding_completed', value: 'true');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                child: Container(
                  height: 70,
                  width: size.width * 0.6,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.primary, // Using primary color from theme
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      currentPage == onBoardData.length - 1
                          ? "Get started!"
                          : "Continue",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    onBoardData.length,
                    (index) => indicatorForSlider(index: index),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  AnimatedContainer indicatorForSlider({int? index}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return AnimatedContainer(
    duration: const Duration(milliseconds: 500),
    width: currentPage == index ? 20 : 10,
    height: 10,
    margin: const EdgeInsets.only(right: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: currentPage == index 
          ? colorScheme.primary 
          : colorScheme.onBackground.withOpacity(0.2), // Use the app's primary color and background color for the indicator
    ),
  );
}


Column onBoardingItems(Size size, int index, BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Column(
    children: [
      Container(
        height: size.height * 0.4,
        width: size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 75,
              bottom: 0,
              right: 0,
              child: SizedBox(
                height: size.height * 0.9,
                width: size.width * 0.9,
                child: Image.asset(
                  onBoardData[index].image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      if (index == 0)
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: colorScheme.primary, // Use primary color from the theme
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "Armstrong"),
            ],
          ),
          textAlign: TextAlign.center,
        )
      else if (index == 1)
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: colorScheme.primary, // Use primary color from the theme
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "It's Okay Not to Be Okay"),
            ],
          ),
          textAlign: TextAlign.center,
        )
      else if (index == 2)
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: colorScheme.primary, // Use primary color from the theme
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "Sorting through the Noise"),
            ],
          ),
          textAlign: TextAlign.center,
        )
      else if (index == 3)
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: colorScheme.primary, // Use primary color from the theme
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "Browse Resources!"),
            ],
          ),
          textAlign: TextAlign.center,
        )
      else if (index == 4)
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: colorScheme.primary, // Use primary color from the theme
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "Find a specialist"),
            ],
          ),
          textAlign: TextAlign.center,
        )
      else if (index == 5)
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 35,
              color: colorScheme.primary, 
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: "Join Us"),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      const SizedBox(height: 10),
      Text(
        onBoardData[index].text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: colorScheme.onBackground, 
        ),
      ),
    ],
  );
}
}