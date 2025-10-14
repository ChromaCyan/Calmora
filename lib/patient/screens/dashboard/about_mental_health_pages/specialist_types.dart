import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpecialistTypes extends StatefulWidget {
  const SpecialistTypes({super.key});

  @override
  State<SpecialistTypes> createState() => _SpecialistTypesState();
}

class _SpecialistTypesState extends State<SpecialistTypes> {
  final Map<String, bool> isExpandedMap = {};

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
          "Calmora's Specialists",
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
          // Background image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.fill,
          ),

          // Blur overlay
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          // Foreground content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/about_mental_health/types_of_specialists.jpg',
                    fit: BoxFit.cover,
                    height: 260,
                    width: double.infinity,
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Who to See and When — Counselor, Psychologist, Psychiatrist",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "In this app, you’ll find three kinds of mental health professionals who can help depending on your situation. "
                  "They are arranged below from the most common, short-term form of support to more clinical, medical-based care. "
                  "Each plays an important role in helping you understand and manage your mental health.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),

                // Counselor Card
                _buildSpecialistCard(
                  title: "1) Counselor — coping strategies & short-term support",
                  imagePath: "images/about_mental_health/counselor.jpg",
                  description:
                      "Overview:\n"
                      "Counselors (sometimes called mental health counselors or licensed professional counselors) usually hold a master’s degree in counseling, psychology, or social work, and are licensed professionals. They offer a practical and supportive space for individuals dealing with everyday life challenges.\n\n"
                      "What they do (role & focus):\n"
                      "Counselors specialize in helping people develop coping strategies, manage stress, improve communication, and handle changes in life circumstances. Their work is often short-term and focused on skill-building and problem-solving.\n\n"
                      "What to expect:\n"
                      "Sessions are conversational, supportive, and collaborative. You’ll learn techniques such as grounding, emotional regulation, and stress management to apply in daily life.\n\n"
                      "When to see a counselor:\n"
                      "If you’re struggling with stress, mild anxiety, life transitions, or need guidance with personal issues — a counselor is a great place to start.",
                ),

                // Psychologist Card
                _buildSpecialistCard(
                  title: "2) Psychologist — assessment & long-term therapy",
                  imagePath: "images/about_mental_health/psychologist.jpg",
                  description:
                      "Overview:\n"
                      "Psychologists hold advanced doctoral degrees (PhD or PsyD) and are trained to diagnose mental health conditions, conduct psychological testing, and provide a variety of evidence-based therapies.\n\n"
                      "What they do (role & focus):\n"
                      "They specialize in long-term therapy to address more complex or recurring issues such as trauma, chronic anxiety, depression, or behavioral challenges. They use structured, research-based treatment models to promote deep healing and personal growth.\n\n"
                      "Therapies they use:\n"
                      "Common approaches include Cognitive Behavioral Therapy (CBT), Dialectical Behavior Therapy (DBT), trauma-focused therapy (like EMDR), and Acceptance and Commitment Therapy (ACT).\n\n"
                      "What to expect:\n"
                      "Sessions may happen weekly or bi-weekly and focus on understanding emotional patterns, developing insight, and creating sustainable changes in thoughts and behaviors.\n\n"
                      "When to see a psychologist:\n"
                      "If you’ve been struggling for a longer time, have experienced trauma, or need structured therapy for emotional or behavioral challenges, a psychologist can help.",
                ),

                // Psychiatrist Card
                _buildSpecialistCard(
                  title: "3) Psychiatrist — medical evaluation & medication management",
                  imagePath: "images/about_mental_health/psychiatrist.jpg",
                  description:
                      "Overview:\n"
                      "Psychiatrists are medical doctors (MD or DO) who specialize in mental health. They can prescribe medications, diagnose complex conditions, and evaluate physical factors that may affect mental wellbeing.\n\n"
                      "What they do (role & focus):\n"
                      "Psychiatrists provide treatment for severe or persistent mental health conditions, including those that may require medication such as major depression, bipolar disorder, or schizophrenia. They often work alongside counselors or psychologists to provide a full treatment plan.\n\n"
                      "Treatment approach:\n"
                      "A psychiatrist may recommend medications such as antidepressants, mood stabilizers, or antipsychotics, while monitoring their effects and adjusting doses as needed. Many also offer therapy or coordinate with therapists for comprehensive care.\n\n"
                      "When to see a psychiatrist:\n"
                      "If your symptoms are severe, include hallucinations, suicidal thoughts, or if therapy alone isn’t enough — you should seek help from a psychiatrist for a medical evaluation.",
                ),

                const SizedBox(height: 25),

                // Text-only "How they work together"
                const Text(
                  "How They Work Together",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Counselors, psychologists, and psychiatrists often collaborate to provide complete mental health care. "
                  "You might start by learning coping tools from a counselor, then move on to therapy with a psychologist for deeper healing, "
                  "and finally consult a psychiatrist if medication is needed. This teamwork ensures you get the right type of care for your needs.",
                  style: TextStyle(fontSize: 16, height: 1.4),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 25),

                // Text-only "Crisis guidance"
                const Text(
                  "If You or Someone You Know is in Crisis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "If someone is in immediate danger, has thoughts of self-harm, or feels unsafe, seek emergency help right away. "
                  "Contact your local emergency services or visit the nearest hospital emergency department. "
                  "You can also reach out to trusted hotlines or crisis services for immediate support. "
                  "Getting help quickly can make a critical difference.",
                  style: TextStyle(fontSize: 16, height: 1.4),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Specialist Card Widget (animated dropdown style)
  Widget _buildSpecialistCard({
    required String title,
    required String description,
    String? imagePath,
  }) {
    final theme = Theme.of(context);
    final isExpanded = isExpandedMap[title] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          isExpandedMap[title] = !isExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(color: Colors.white.withOpacity(0.15)),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 6,
          //     offset: const Offset(2, 3),
          //   ),
          // ],
        ),
        child: Column(
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 20,
                ),
              ],
            ),

            // Animated description
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePath != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
