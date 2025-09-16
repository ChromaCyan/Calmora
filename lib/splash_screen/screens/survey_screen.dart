import 'package:flutter/material.dart';
import 'package:armstrong/splash_screen/models/survey_message.dart';
import 'package:armstrong/patient/screens/survey/questions_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  bool _surveyOnboardingCompleted = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await _storage.read(key: 'userId');
    _checkSurveyOnboardingStatus();
  }

  Future<void> _checkSurveyOnboardingStatus() async {
    if (_userId == null) return;
    String? completed =
        await _storage.read(key: 'survey_onboarding_completed_$_userId');
    if (completed == 'true') {
      setState(() => _surveyOnboardingCompleted = true);
      _navigateToSurvey();
    }
  }

  void _navigateToSurvey() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => QuestionScreen()),
      (route) => false,
    );
  }

  void _onNextPressed() async {
    if (_currentPage.value == onBoardData.length - 1) {
      // ✅ FIX: use user-specific key
      await _storage.write(
        key: 'survey_onboarding_completed_$_userId',
        value: 'true',
      );
      _navigateToSurvey();
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
    if (_surveyOnboardingCompleted) return Container();

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image (same style as Splash)
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
          ),

          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.06),

                    Text(
                      "SURVEY",
                      style: GoogleFonts.montserrat(
                        fontSize: size.height * 0.045,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Divider(
                      thickness: 3,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      indent: 140,
                      endIndent: 140,
                    ),
                    Text(
                      "Personalize Your Dashboard",
                      style: GoogleFonts.montserrat(
                        fontSize: size.height * 0.022,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
                        itemCount: onBoardData.length,
                        controller: _pageController,
                        onPageChanged: (value) => _currentPage.value = value,
                        itemBuilder: (context, index) => _OnboardingItem(
                          size: size,
                          index: index,
                        ),
                      ),
                    ),

                    /// Progress Indicator
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 120),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: theme.brightness == Brightness.light
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
                                  (index) =>
                                      _Indicator(isActive: value == index),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Buttons
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
                              const SizedBox(width: 50),
                            _NextButton(
                              isLastPage: value == onBoardData.length - 1,
                              onPressed: _onNextPressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ),
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

  String _getTitle(int index) {
    const titles = [
      "Why Survey?",
      "Personalize Your Dashboard",
      "We Care About You",
    ];
    return titles[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(height: size.height * 0.05),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const _NextButton({required this.isLastPage, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(
        isLastPage ? "Start Survey" : "Next",
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _PreviousButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PreviousButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Color splashColor = Colors.grey.withOpacity(0.3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: splashColor,
        onTap: onPressed,
        child: const SizedBox(
          height: 50,
          width: 50,
          child: Icon(Icons.arrow_back_ios_outlined, color: Colors.grey, size: 28),
        ),
      ),
    );
  }
}

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
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onBackground.withOpacity(0.2),
      ),
    );
  }
}
