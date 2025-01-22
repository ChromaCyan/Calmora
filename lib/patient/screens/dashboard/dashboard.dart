import 'package:armstrong/widgets/buttons/survey_button.dart';
import 'package:armstrong/widgets/cards/article_card.dart';
import 'package:armstrong/widgets/cards/daily_advice_card.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/mood_card.dart';
import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              WelcomeSection(),
              const SizedBox(height: 30),
              // MoodSection(),
              // const SizedBox(height: 20),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment
              //       .center, 
              //   crossAxisAlignment: CrossAxisAlignment
              //       .center,
              //   children: [
              //     Center(
              //       child: QuickTestButton(),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 20),
              JournalSection(),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Text(
                'Articles For You.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ArticleCard(
                      imagePath: 'assets/image1.jpg',
                      title: 'Men’s Mental Health Matters!',
                      author: 'Dr. Juan Joe Cruz',
                    ),
                    ArticleCard(
                      imagePath: 'assets/image2.jpg',
                      title: 'Reasons Why You Are Broken...',
                      author: 'Dr. Leslie Ferrer',
                    ),
                    ArticleCard(
                      imagePath: 'assets/image2.jpg',
                      title: 'Reasons Why You Are Broken...',
                      author: 'Dr. Leslie Ferrer',
                    ),
                    ArticleCard(
                      imagePath: 'assets/image2.jpg',
                      title: 'Reasons Why You Are Broken...',
                      author: 'Dr. Leslie Ferrer',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              HealthAdviceSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
