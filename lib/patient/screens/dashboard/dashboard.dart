import 'package:armstrong/patient/screens/dashboard/men_health.dart';
import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/mood_graph.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/cards/meditation_card.dart';
import 'package:armstrong/widgets/cards/app_section.dart';
import 'package:armstrong/patient/screens/dashboard/meditation_details.dart';
import 'package:armstrong/patient/screens/dashboard/breathing_details.dart';
import 'package:armstrong/patient/screens/dashboard/emergency_services.dart';
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
                      title: "Understanding Mental Health",
                      imageUrl: "images/splash/image6.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return MentalHealthAwarenessPage();  // Destination page
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Fade transition
                              var slideAnimation = Tween<Offset>(
                                begin: Offset(1.0, 0.0), // Slide from the right
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                              return SlideTransition(position: slideAnimation, child: child);
                            },
                          ),
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
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return EmergencyServicePage();  
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var slideAnimation = Tween<Offset>(
                                begin: Offset(1.0, 0.0), 
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                              return SlideTransition(position: slideAnimation, child: child);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: AppSection(
                      title: "What is Calmora?",
                      imageUrl: "images/Calmora.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return AboutUsPage(); 
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var slideAnimation = Tween<Offset>(
                                begin: Offset(1.0, 0.0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                              return SlideTransition(position: slideAnimation, child: child);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  'Mind & Body Wellness',
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
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return MindfulMeditation();  // Destination page
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Fade transition
                              var slideAnimation = Tween<Offset>(
                                begin: Offset(1.0, 0.0), // Slide from the right
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                              return SlideTransition(position: slideAnimation, child: child);
                            },
                          ),
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
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return BreathingGuideScreen();  
                            },
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Fade transition
                              var slideAnimation = Tween<Offset>(
                                begin: Offset(1.0, 0.0), 
                                end: Offset.zero,
                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                              return SlideTransition(position: slideAnimation, child: child);
                            },
                          ),
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

              // Removed Journal Section
              // Center(
              //   child: Text(
              //     'What is on your mind?',
              //     style: theme.textTheme.titleLarge?.copyWith(
              //       fontWeight: FontWeight.bold,
              //       color: theme.colorScheme.onBackground,
              //     ),
              //   ),
              // ),       
              // const JournalSection(),

              Center(
                child: Text(
                  'Recommended Articles',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),

              // Article List
              const ArticleList(),

              const SizedBox(height: 30),

              // Removed Daily Mood Chart
              // Center(
              //   child: Text(
              //     'Weekly Mood Chart',
              //     style: theme.textTheme.headlineSmall?.copyWith(
              //       fontWeight: FontWeight.bold,
              //       color: theme.colorScheme.onBackground,
              //     ),
              //   ),
              // ),

              // Center(
              //   child: _userId != null
              //       ? MoodCalendarScreen(userId: _userId!)
              //       : const Center(child: CircularProgressIndicator()),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
