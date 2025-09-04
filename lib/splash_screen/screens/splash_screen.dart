import 'package:flutter/material.dart';
import 'package:armstrong/config/colors.dart';
import 'package:armstrong/splash_screen/models/splash_message.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/authentication/screens/login_screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:armstrong/services/socket_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onNextPressed() async {
    if (_currentPage.value == onBoardData.length - 1) {
      await _storage.write(key: 'onboarding_completed', value: 'true');
      _navigateToLogin();
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
              SizedBox(height: height * 0.1),  // Adjust the initial spacing dynamically
              Expanded(
                child: PageView.builder(
                  itemCount: onBoardData.length,
                  controller: _pageController,
                  onPageChanged: (value) => _currentPage.value = value,
                  itemBuilder: (context, index) => _OnboardingItem(size: size, index: index),
                ),
              ),
              const SizedBox(height: 10),
              ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (_, value, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onBoardData.length,
                    (index) => _Indicator(isActive: value == index),
                  ),
                ),
              ),
              const SizedBox(height: 15), // Reduce the spacing between the indicator and buttons
              ValueListenableBuilder<int>(
                valueListenable: _currentPage,
                builder: (_, value, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35), // optional horizontal padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (value > 0)
                      _PreviousButton(onPressed: _onPreviousPressed)
                      else
                      SizedBox(width: 50), // keep space when no previous button

                      _NextButton(
                        isLastPage: value == onBoardData.length - 1,
                        onPressed: _onNextPressed,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.05), // Adjust the bottom padding dynamically
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem extends StatelessWidget {
  final Size size;
  final int index;

  const _OnboardingItem({required this.size, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          height: size.height * 0.3,  // Adjust image height dynamically
          width: size.width * 0.7,    // Adjust image width dynamically
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
          child: Image.asset(onBoardData[index].image, fit: BoxFit.contain),
        ),
        SizedBox(height: size.height * 0.05),  // Adjust spacing between image and title dynamically
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _getTitle(index),
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: size.height * 0.04,  // Adjust font size dynamically
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            onBoardData[index].text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: size.height * 0.025, color: theme.colorScheme.onBackground),
          ),
        ),
      ],
    );
  }

  String _getTitle(int index) {
    const titles = [
      "Calmora",
      // "It's Okay\nto Not be Okay",
      // "Sorting through\nthe Noise",
      "Browse Resources!",
      "Find a Specialist",
      "Join Us",
    ];
    return titles[index];
  }
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
