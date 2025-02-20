import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/mood_graph.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/buttons/survey_button.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
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
                  'Write about your day!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
