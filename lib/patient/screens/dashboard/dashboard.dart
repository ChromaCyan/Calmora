import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:armstrong/widgets/buttons/survey_button.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:armstrong/widgets/cards/daily_advice_card.dart';
import 'package:armstrong/widgets/banners/patient_banner_card.dart'; // New import
import 'package:armstrong/patient/models/widgets/banner_model.dart'; // New import
import 'package:armstrong/helpers/onboard_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _welcomeKey = GlobalKey();
  final GlobalKey _adviceKey = GlobalKey();
  final GlobalKey _journalKey = GlobalKey();
  final GlobalKey _articleKey = GlobalKey();
  final GlobalKey _quickTestKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!hasCompletedOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          _welcomeKey,
          _adviceKey,
          _journalKey,
          _articleKey,
          _quickTestKey,
        ]);
      });

      // Set onboarding as completed
      await prefs.setBool('hasCompletedOnboarding', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(  // Wrap with ShowCaseWidget for onboarding
      builder: (context) => Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Highlight Welcome Section
                Showcase(
                  key: _welcomeKey,
                  description: "This is your welcome section where you get personalized greetings.",
                  child: WelcomeSection(),
                ),
                const SizedBox(height: 30),

                // Highlight Carousel Banner Section (new addition)
                Showcase(
                  key: _adviceKey,
                  description: "Here is the carousel banner displaying important info.",
                  child: HealthAdviceSection(
                  items: carouselData
                )
                ),
                const SizedBox(height: 30),

                // Highlight Health Advice Section
                Showcase(
                  key: _adviceKey,
                  description: "Here, you'll find daily advice to improve your well-being.",
                  child: HealthAdviceSection(items: carouselData),
                ),
                const SizedBox(height: 30),

                // Highlight Journal Section
                Showcase(
                  key: _journalKey,
                  description: "Write your thoughts and feelings in your personal journal.",
                  child: JournalSection(),
                ),
                const SizedBox(height: 30),

                // Highlight Article List
                Showcase(
                  key: _articleKey,
                  description: "Check out the latest articles recommended for you.",
                  child: ArticleList(),
                ),
                const SizedBox(height: 30),

                // Highlight Quick Test Button
                Showcase(
                  key: _quickTestKey,
                  description: "Tap here to take a quick mental health assessment.",
                  child: Center(child: QuickTestButton()),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
