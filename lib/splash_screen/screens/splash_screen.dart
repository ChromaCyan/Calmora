import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:armstrong/splash_screen/models/splash_message.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:armstrong/services/socket_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:armstrong/authentication/screens/usertype_select_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool onboardingCompleted = false;
  final socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    String? completed = await _storage.read(key: 'onboarding_completed');
    if (completed == 'true') {
      setState(() {
        onboardingCompleted = true;
      });
      _navigateToUserTypeSelectScreen();
    }
  }

  // void _navigateToUserTypeSelectScreen() {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (_) => const RegistrationScreen()),
  //     (route) => false,
  //   );
  // }

  void _navigateToUserTypeSelectScreen() {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const RegistrationScreen(),
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0); // Slide from right to left
        const end = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ),
    (route) => false,
  );
}


  void _onNextPressed() async {
    if (_currentPage.value == onBoardData.length - 1) {
      await _storage.write(key: 'onboarding_completed', value: 'true');
      _navigateToUserTypeSelectScreen();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _onPreviousPressed() {
    if (_currentPage.value > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (onboardingCompleted) return Container();

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final double width = size.width;
    final double height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: theme.colorScheme.background)),
          Column(
            mainAxisAlignment: MainAxisAlignment.start, 
            children: [
              SizedBox(height: height * 0.1),
              Text(
                "CALMORA",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: size.height * 0.055,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              Divider(
                thickness: 3,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                indent: 140,
                endIndent: 140,
              ),
              Text(
                "Mental Health App",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: size.height * 0.025,
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: onBoardData.length,
                  controller: _pageController,
                  onPageChanged: (value) => _currentPage.value = value,
                  itemBuilder: (context, index) => _OnboardingItem(size: size, index: index),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.6),
                        ),
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: _currentPage,
                        builder: (_, value, __) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onBoardData.length,
                            (index) => _Indicator(isActive: value == index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (_, value, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (value > 0)
                      _PreviousButton(onPressed: _onPreviousPressed)
                      else
                      SizedBox(width: 50),
                      _NextButton(
                        isLastPage: value == onBoardData.length - 1,
                        onPressed: _onNextPressed,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem extends StatefulWidget {
  final Size size;
  final int index;

  const _OnboardingItem({required this.size, required this.index, Key ? key}) : super(key: key);

  @override
  State<_OnboardingItem> createState() => _OnboardingItemState();
}

class _OnboardingItemState extends State<_OnboardingItem> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0), // start slightly below
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTitle(int index) {
    const titles = [
      "Welcome",
      "Browse Resources!",
      "AI Assistance",
      "Find a Specialist",
      "Find Peace",
    ];
    return titles[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = widget.size;
    final index = widget.index;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: theme.brightness == Brightness.light
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getTitle(index),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: size.height * 0.027,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: size.height * 0.3,
              width: size.width * 0.7,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Image.asset(onBoardData[index].image, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                onBoardData[index].text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.height * 0.020,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // String _getTitle(int index) {
  //   const titles = [
  //     "Welcome",
  //     // "It's Okay\nto Not be Okay",
  //     // "Sorting through\nthe Noise",
  //     "Browse Resources!",
  //     "AI Assistance",
  //     "Find a Specialist",
  //     "Find Peace",
  //   ];
  //   return titles[index];
  // }
}


//✅✅✅<<<---Next Button--->>>✅✅✅
class _NextButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const _NextButton({required this.isLastPage, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Color textColor = isLastPage
    //     ? Colors.white
    //     : (theme.brightness == Brightness.dark ? Colors.black : Colors.white);
    final Color iconColor = isLastPage ? Colors.green : Colors.grey;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          height: 50,
          width: 50,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: iconColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}


//✅✅✅<<<---Previous Button--->>>✅✅✅
class _PreviousButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PreviousButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color splashColor = Colors.grey.withOpacity(0.3);   

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: splashColor,
        onTap: onPressed,
        child: Container(
          height: 50,
          width: 50,
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }
}


//✅✅✅<<<---Progress Bar/Dots--->>>✅✅✅
class _Indicator extends StatelessWidget {
  final bool isActive;

  const _Indicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isActive ? 20 : 10,
      height: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onBackground.withOpacity(0.2),
      ),
    );
  }
}
