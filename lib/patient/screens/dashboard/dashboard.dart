import 'package:armstrong/patient/screens/dashboard/about_app_pages/awareness.dart';
import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/mood_graph.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:armstrong/widgets/cards/guide_card.dart';
import 'package:armstrong/widgets/cards/app_section.dart';
import 'package:armstrong/widgets/cards/hotline_card.dart';
import 'package:armstrong/patient/screens/dashboard/hotlines_screen.dart';

import 'package:armstrong/patient/screens/dashboard/mind_body_pages/meditation_details.dart';
import 'package:armstrong/patient/screens/dashboard/mind_body_pages/breathing_details.dart';
import 'package:armstrong/patient/screens/dashboard/about_app_pages/emergency_services.dart';
import 'package:armstrong/patient/screens/dashboard/about_app_pages/about_us.dart';
import 'package:armstrong/patient/screens/dashboard/about_app_pages/faq.dart';
import 'package:armstrong/patient/screens/dashboard/about_mental_health_pages/mental_disorder.dart';
import 'package:armstrong/patient/screens/dashboard/about_mental_health_pages/mental_health.dart';
import 'package:armstrong/patient/screens/dashboard/about_mental_health_pages/specialist_types.dart';
import 'package:armstrong/patient/screens/dashboard/about_mental_health_pages/types_of_mental_disorder.dart';

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

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 12),

              const SizedBox(height: 10),
              Center(
                child: Text(
                  'About Mental Health',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //cards part
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GuideCard(
                      title: "What is Mental Health?",
                      imageUrl: "images/about_mental_health/mental_health.jpg",
                      onTap: () => _navigateWithSlide(context, MentalHealth()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GuideCard(
                      title: "What is a Mental Disorder?",
                      imageUrl:
                          "images/about_mental_health/mental_disorder.jpg",
                      onTap: () =>
                          _navigateWithSlide(context, MentalDisorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GuideCard(
                      title: "Common types of mental disorder",
                      imageUrl: "images/about_mental_health/depress.jpg",
                      onTap: () => _navigateWithSlide(context, DisorderTypes()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GuideCard(
                      title: "Calmora Specialists and who should you seek",
                      imageUrl:
                          "images/about_mental_health/types_of_specialists.jpg",
                      onTap: () =>
                          _navigateWithSlide(context, SpecialistTypes()),
                    ),
                  ),
                ],
              ),
              const Divider(
                thickness: 1.5,
                color: Colors.grey,
                indent: 40,
                endIndent: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                    child: Text(
                      "Need Immediate Call? \n\ Press the red button.",
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: HotlineCard(
                      imagePath: "images/hotline_icon2.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    HotlinesScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              final tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.red,
                    size: 15,
                  ),
                ],
              ),

              const Divider(
                thickness: 1.5,
                color: Colors.grey,
                indent: 40,
                endIndent: 40,
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Recommended Articles',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const ArticleList(),

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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GuideCard(
                      title: "Meditation Exercise Guide",
                      imageUrl: "images/meditation2.jpeg",
                      onTap: () =>
                          _navigateWithSlide(context, MindfulMeditation()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GuideCard(
                      title: "Breathing Exercise Guide",
                      imageUrl: "images/breathing_exercise_dp.jpg",
                      onTap: () =>
                          _navigateWithSlide(context, BreathingGuideScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 1.5,
                color: Colors.grey,
                indent: 40,
                endIndent: 40,
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  'What is this app about?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AppSection(
                      title: "For Awareness",
                      imageUrl: "images/splash/image6.png",
                      onTap: () => _navigateWithSlide(
                          context, MentalHealthAwarenessPage()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Expanded(
                  //   child: AppSection(
                  //     title: "Hotline Services",
                  //     imageUrl: "images/splash/image7.png",
                  //     onTap: () =>
                  //         _navigateWithSlide(context, EmergencyServicePage()),
                  //   ),
                  // ),
                  // const SizedBox(width: 10),
                  Expanded(
                    child: AppSection(
                      title: "FAQ",
                      imageUrl: "images/splash/image2.png",
                      onTap: () => _navigateWithSlide(
                          context, FrequentlyAskedQuestions()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppSection(
                      title: "About Calmora",
                      imageUrl: "images/calmora_circle_crop.png",
                      onTap: () => _navigateWithSlide(context, AboutUsPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateWithSlide(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var slideAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(position: slideAnimation, child: child);
        },
      ),
    );
  }
}
