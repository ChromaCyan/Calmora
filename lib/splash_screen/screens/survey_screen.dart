import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For handling back button event
import 'package:armstrong/splash_screen/models/survey_message.dart';
import 'package:armstrong/patient/screens/survey/questions_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  bool surveyOnboardingCompleted = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _checkSurveyOnboardingStatus();
  }

  Future<void> _loadUserId() async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'userId');
  }

  // Function to check if survey onboarding is completed
  Future<void> _checkSurveyOnboardingStatus() async {
    if (_userId == null) return;

    final storage = FlutterSecureStorage();
    String? completed = await storage.read(key: 'survey_onboarding_completed_$_userId');
    if (completed == 'true') {
      setState(() {
        surveyOnboardingCompleted = true;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => QuestionScreen()),
        (route) => false,
      );
    }
  }

  Future<bool> _onWillPop() async {
    // Handle back press logic
    return surveyOnboardingCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.background,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: PageView.builder(
                    itemCount: onBoardData.length,
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      return onBoardingItems(
                        MediaQuery.of(context).size,
                        index,
                        context,
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (currentPage == onBoardData.length - 1) {
                      final storage = FlutterSecureStorage();
                      // Mark survey onboarding as complete
                      await storage.write(
                          key: 'survey_onboarding_completed', value: 'true');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionScreen(),
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
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        currentPage == onBoardData.length - 1
                            ? "Start Survey!"
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer indicatorForSlider({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: currentPage == index ? 20 : 10,
      height: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
      ),
    );
  }

  Column onBoardingItems(Size size, int index, BuildContext context) {
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
        Text(
          onBoardData[index].text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.5,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
}
