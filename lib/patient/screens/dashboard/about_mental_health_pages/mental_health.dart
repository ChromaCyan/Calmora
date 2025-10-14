import 'dart:ui';
import 'package:flutter/material.dart';

class MentalHealth extends StatelessWidget {
  const MentalHealth({super.key});

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
          "Understanding Mental Health",
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
                    'images/about_mental_health/mental_health.jpg', 
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "What is Mental Health?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Mental health refers to our emotional, psychological, and social well-being. "
                  "It affects how we think, feel, and act in our daily lives. It also determines "
                  "how we handle stress, relate to others, and make decisions. Mental health is "
                  "not just the absence of mental illness — it’s about maintaining a balanced, "
                  "positive, and resilient state of mind.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 20),
                const Text(
                  "Why Mental Health Matters",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Good mental health is essential to living a fulfilling life. "
                  "It influences every aspect of who we are — our relationships, our work, "
                  "our physical health, and even how we perceive ourselves. "
                  "When our mental health is stable, we can better cope with life's challenges, "
                  "learn new skills, and contribute positively to our communities.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 20),
                const Text(
                  "Common Factors That Affect Mental Health:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text.rich(
                  TextSpan(
                    children: [
                      _boldBullet("Biological factors"),
                      _normal(" - such as genetics, brain chemistry, or physical health conditions.\n\n"),
                      _boldBullet("Life experiences"),
                      _normal(" - including trauma, abuse, or significant stress.\n\n"),
                      _boldBullet("Family history"),
                      _normal(" - having a family background of mental health problems can increase risk.\n\n"),
                      _boldBullet("Lifestyle choices"),
                      _normal(" - such as lack of sleep, poor diet, or substance use can affect mood and energy levels.\n"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/about_mental_health/r_u_ok.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "How to Take Care of Your Mental Health:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Text.rich(
                  TextSpan(
                    children: [
                      _boldBullet("Stay connected"),
                      _normal(" - Spend time with supportive friends and family. Healthy relationships can boost your sense of belonging and happiness.\n\n"),
                      _boldBullet("Practice self-care"),
                      _normal(" - Engage in activities you enjoy, get enough rest, eat nutritious food, and exercise regularly.\n\n"),
                      _boldBullet("Manage stress"),
                      _normal(" - Try mindfulness, meditation, or breathing exercises to calm your mind and stay present.\n\n"),
                      _boldBullet("Seek help when needed"),
                      _normal(" - Talking to a counselor, psychologist, or therapist is a sign of strength, not weakness.\n\n"),
                      _boldBullet("Set realistic goals"),
                      _normal(" - Break tasks into small steps and celebrate your progress along the way.\n\n"),
                      _boldBullet("Limit negative input"),
                      _normal(" - Be mindful of media consumption and social comparisons that can lower self-esteem.\n"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Remember: Taking care of your mind is just as important as taking care of your body. "
                  "Mental health allows you to enjoy life, stay productive, and build meaningful connections with others. "
                  "Prioritize your well-being — you deserve it.",
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
