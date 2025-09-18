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

        // 🟢 Scroll only inside this container
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AppSection(
                      title: "Understanding Mental Health",
                      imageUrl: "images/splash/image6.png",
                      onTap: () => _navigateWithSlide(
                          context, MentalHealthAwarenessPage()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppSection(
                      title: "Emergency Services",
                      imageUrl: "images/splash/image7.png",
                      onTap: () =>
                          _navigateWithSlide(context, EmergencyServicePage()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppSection(
                      title: "What is Calmora?",
                      imageUrl: "images/calmora_circle_crop.png",
                      onTap: () => _navigateWithSlide(context, AboutUsPage()),
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
