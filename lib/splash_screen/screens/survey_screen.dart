import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:armstrong/splash_screen/models/survey_message.dart';
import 'package:armstrong/patient/screens/survey/questions_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _surveyOnboardingCompleted = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'userId');
    _checkSurveyOnboardingStatus();
  }

  Future<void> _checkSurveyOnboardingStatus() async {
    if (_userId == null) return;
    
    final storage = FlutterSecureStorage();
    String? completed =
        await storage.read(key: 'survey_onboarding_completed_$_userId');
    
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _surveyOnboardingCompleted,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Onboarding Content
                  Expanded(
                    flex: 7,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: onBoardData.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) => _buildOnboardingItem(index, constraints.maxWidth, constraints.maxHeight),
                    ),
                  ),

                  // Navigation Button
                  _buildNavigationButton(constraints.maxWidth),

                  // Page Indicators
                  _buildPageIndicators(),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Builds onboarding content for each page
  Widget _buildOnboardingItem(int index, double maxWidth, double maxHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Container
          SizedBox(
            height: maxHeight * 0.4,
            width: maxWidth * 0.8,
            child: Image.asset(
              onBoardData[index].image,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          // Title Text
          Text(
            _getOnboardingTitle(index),
            style: TextStyle(
              fontSize: maxWidth * 0.08, // Responsive font size
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // Description Text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.1),
            child: Text(
              onBoardData[index].text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: maxWidth * 0.045,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds navigation button (Continue/Start Survey)
Widget _buildNavigationButton(double maxWidth) {
  return GestureDetector(
    onTap: () async {
      if (_currentPage == onBoardData.length - 1) {
        final storage = FlutterSecureStorage();
        await storage.write(key: 'survey_onboarding_completed', value: 'true');
        _navigateToSurvey();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      height: 60,
      width: maxWidth * 0.6,
      decoration: BoxDecoration(
        color: _currentPage == onBoardData.length - 1
            ? Colors.green
            : Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.withOpacity(0.5) // Grey shadow for dark mode
                : Colors.black.withOpacity(0.2), // Black shadow for light mode
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _currentPage == onBoardData.length - 1 ? "Start Survey!" : "Continue",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _currentPage == onBoardData.length - 1
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
          ),
        ),
      ),
    ),
  );
}

  /// Builds page indicators (dots)
  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onBoardData.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: _currentPage == index ? 20 : 10,
          height: 10,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  /// Gets onboarding title
  String _getOnboardingTitle(int index) {
    const titles = [
      "Why Survey?",
      "To personalize your dashboard..",
      "We care about you!",
    ];
    return titles[index];
  }
}