import 'dart:ui';
import 'package:flutter/material.dart';

class MentalDisorder extends StatelessWidget {
  const MentalDisorder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Understanding Mental Disorder",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.fill,
          ),

          /// Blur + overlay
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          /// Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/about_mental_health/mental_disorder.jpg',
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "What is a Mental Disorder?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Mental disorders, also known as mental illnesses, are conditions that affect a person's "
                  "thinking, feeling, behavior, or mood. These disorders can impact how individuals handle "
                  "stress, relate to others, and make decisions. Having a mental disorder does not mean someone "
                  "is weak or flawed — it means they are experiencing challenges in mental functioning that can "
                  "often be treated or managed with the right support and care.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 20),
                const Text(
                  "Mental Health vs. Mental Disorder",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Mental health refers to a state of emotional and psychological well-being — it’s how we think, "
                  "feel, and act in our daily lives. A mental disorder, on the other hand, occurs when there are "
                  "disruptions or imbalances in those areas that significantly interfere with day-to-day functioning. "
                  "In simple terms, everyone has mental health, but not everyone will experience a mental disorder.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/about_mental_health/lonely_guy.jpg',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Common Signs or Symptoms:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text.rich(
                  TextSpan(
                    children: [
                      _boldBullet("Persistent sadness or emptiness"),
                      _normal(" - lasting for weeks or months, not just occasional sadness.\n\n"),
                      _boldBullet("Extreme mood changes"),
                      _normal(" - feeling very high and energetic, then very low and hopeless.\n\n"),
                      _boldBullet("Withdrawal from friends or activities"),
                      _normal(" - losing interest in things that once brought joy.\n\n"),
                      _boldBullet("Changes in sleep or appetite"),
                      _normal(" - sleeping too much or too little, eating significantly more or less than usual.\n\n"),
                      _boldBullet("Difficulty concentrating or making decisions"),
                      _normal(" - feeling mentally foggy or disconnected.\n\n"),
                      _boldBullet("Intense fear, worry, or guilt"),
                      _normal(" - feeling anxious or overwhelmed even without a clear reason.\n\n"),
                      _boldBullet("Unusual thinking or perceptions"),
                      _normal(" - hearing, seeing, or believing things that aren’t real.\n\n"),
                      _boldBullet("Thoughts of self-harm or hopelessness"),
                      _normal(" - these are serious signs that immediate help is needed.\n"),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/about_mental_health/suffering_inside.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Causes and Contributing Factors:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text.rich(
                  TextSpan(
                    children: [
                      _boldBullet("Genetic and biological factors"),
                      _normal(" - family history, brain chemistry, or hormonal imbalances can increase risk.\n\n"),
                      _boldBullet("Environmental factors"),
                      _normal(" - exposure to stress, violence, trauma, or neglect can trigger mental health problems.\n\n"),
                      _boldBullet("Life experiences"),
                      _normal(" - grief, loss, or major life changes can deeply impact emotional stability.\n\n"),
                      _boldBullet("Substance use"),
                      _normal(" - misuse of alcohol or drugs can contribute to or worsen mental disorders.\n"),
                    ],
                  ),
                ),

                const Text(
                  "Raising awareness about mental disorders helps break the stigma that often prevents people from seeking help. "
                  "With understanding and compassion, we can create an environment where individuals feel safe to talk about "
                  "their struggles and access proper treatment. Early support, therapy, and a caring community can make a "
                  "tremendous difference in recovery and overall quality of life.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 20),
                const Text(
                  "Mental disorders are health conditions — not personal failings. "
                  "With proper care, understanding, and patience, individuals can live meaningful, fulfilling lives.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

TextSpan _boldBullet(String text) {
  return TextSpan(
    text: "\u2022  $text",
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );
}

TextSpan _normal(String text) {
  return TextSpan(
    text: text,
    style: const TextStyle(fontSize: 16),
  );
}
