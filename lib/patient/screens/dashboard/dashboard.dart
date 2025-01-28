import 'package:armstrong/widgets/buttons/survey_button.dart';
import 'package:armstrong/widgets/cards/article_card.dart';
import 'package:armstrong/widgets/cards/daily_advice_card.dart';
import 'package:armstrong/widgets/cards/journal_card.dart';
import 'package:armstrong/widgets/cards/mood_card.dart';
import 'package:armstrong/widgets/cards/welcome_card.dart';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/cards/article_list.dart';
import 'package:armstrong/widgets/banners/patient_banner_card.dart';
import 'package:armstrong/patient/models/widgets/banner_model.dart';

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
              Center(
                child: HealthAdviceSection(
                  items: carouselData
                )
              ),
              const SizedBox(height: 30),
              Center(
                child: JournalSection()
              ),
              const SizedBox(height: 30),
              Center(
                child: ArticleList()
              ),
              const SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, 
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: [
                  Center(
                    child: QuickTestButton(),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
