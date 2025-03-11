import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:armstrong/widgets/charts/survey_result.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/mood_graph.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

              // Pie chart for survey result
              Center(
                child: _userId != null
                    ? SurveyScoreChart(patientId: _userId!)
                    : Center(child: CircularProgressIndicator()),
              ),

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
                    ? MoodCalendarScreen(
                        userId: _userId!) // Remove the SizedBox limit
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
