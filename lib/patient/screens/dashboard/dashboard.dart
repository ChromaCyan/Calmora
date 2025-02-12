import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/cards/mood_graph.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/buttons/survey_button.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:armstrong/config/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    bool hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

    if (!hasCompletedOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context)
            .startShowCase([_journalKey, _articleKey, _quickTestKey]);
      });

      // Set onboarding as completed
      await prefs.setBool('hasCompletedOnboarding', true);
    }
  }

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context); // Get the current theme

  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            const WelcomeSection(),

            const SizedBox(height: 30),

            // Highlight Survey Card
            Showcase(
              key: _quickTestKey,
              description: "Tap here to take a quick mental health assessment.",
              textColor: theme.colorScheme.onPrimary, 
              tooltipBackgroundColor: theme.colorScheme.primary, 
              targetPadding: const EdgeInsets.all(12),
              targetShapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(child: QuickTestButton()),
            ),
            const SizedBox(height: 30),

            Center(
              child: Text(
                'Write about your day!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground, 
                ),
              ),
            ),

            // Highlight Journal Card
            Showcase(
              key: _journalKey,
              description: "Write your thoughts and feelings in your personal journal.",
              textColor: theme.colorScheme.onPrimary,
              tooltipBackgroundColor: theme.colorScheme.primary,
              targetPadding: const EdgeInsets.all(10),
              targetShapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const JournalSection(),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'Recommended Articles for you!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),

            // Highlight Article List
            Showcase(
              key: _articleKey,
              description: "Check out the latest articles recommended for you.",
              textColor: theme.colorScheme.onPrimary,
              tooltipBackgroundColor: theme.colorScheme.primary,
              targetPadding: const EdgeInsets.all(10),
              targetShapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const ArticleList(),
            ),
            const SizedBox(height: 30),

            Center(
              child: Text(
                'Weekly Mood Chart',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ),

            SizedBox(
              height: 300,
              child: const MoodChartScreen(),
            ),
          ],
        ),
      ),
    ),
  );
}
}