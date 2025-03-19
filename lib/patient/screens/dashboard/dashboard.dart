import 'package:armstrong/patient/screens/dashboard/men_health.dart';
import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:armstrong/widgets/charts/survey_result.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/mood_graph.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/cards/meditation_card.dart';
import 'package:armstrong/widgets/cards/app_section.dart';
import 'package:armstrong/patient/screens/dashboard/meditation_details.dart';
import 'package:armstrong/patient/screens/dashboard/breathing_details.dart';
import 'package:armstrong/patient/screens/dashboard/about_us.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.read(key: 'userId');
    setState(() {
      _userId = userId;
    });

    if (_userId != null) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Center(
                child: Text(
                  'What is this app about?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),

              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AppSection(
                      title: "Men's Mental health awareness!",
                      imageUrl: "images/splash/image6.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BreathingGuideScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: AppSection(
                      title: "Emergency Services",
                      imageUrl: "images/splash/image7.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BreathingGuideScreen()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: AppSection(
                      title: "What is Armstrong?",
                      imageUrl: "images/armstrong_white.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutUsPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  'Exercises you can do!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GuideCard(
                      title: "Meditation Exercise Guide",
                      imageUrl: "images/meditation.jpg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MindfulMeditation()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GuideCard(
                      title: "Breathing Exercise Guide",
                      imageUrl: "images/breath.jpg",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BreathingGuideScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // // Pie chart for survey result
              // Center(
              //   child: _userId != null
              //       ? SurveyScoreChart(patientId: _userId!)
              //       : Center(child: CircularProgressIndicator()),
              // ),

              const SizedBox(height: 20),

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
              const JournalSection(),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  'Recommended Articles For You!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),

              // Article List
              const ArticleList(),

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

              Center(
                child: _userId != null
                    ? MoodCalendarScreen(userId: _userId!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
