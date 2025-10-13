import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisorderTypes extends StatefulWidget {
  const DisorderTypes({super.key});

  @override
  State<DisorderTypes> createState() => _DisorderTypesState();
}

class _DisorderTypesState extends State<DisorderTypes> {
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
          "Types of Mental Disorders",
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/about_mental_health/depress.jpg',
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Common Types of Mental Disorders",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Mental disorders affect individuals in unique ways, influencing their emotions, thoughts, "
                  "and behaviors. Below are some of the most common types, each with a brief overview "
                  "to help you understand their general nature and impact.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 20),

                /// Dropdown list (custom design)
                _buildDisorderCard(
                  title: "Anxiety Disorders",
                  description:
                      "Anxiety disorders are characterized by excessive fear, worry, or nervousness that interferes with daily life. "
                      "People with anxiety disorders may experience restlessness, rapid heartbeat, or trouble focusing. "
                      "Therapy, mindfulness, and sometimes medication can help manage symptoms.",
                ),
                _buildDisorderCard(
                  title: "Depressive Disorders",
                  description:
                      "Depressive disorders involve prolonged sadness, hopelessness, or lack of interest in activities once enjoyed. "
                      "They can affect mood, sleep, appetite, and motivation. Treatment may include therapy, lifestyle changes, "
                      "and, in some cases, antidepressant medication.",
                ),
                _buildDisorderCard(
                  title: "Bipolar Disorder",
                  description:
                      "Bipolar disorder causes shifts between emotional highs (mania) and lows (depression). "
                      "Manic phases bring increased energy or impulsive behavior, while depressive phases bring fatigue or despair. "
                      "Long-term care often includes therapy, medication, and self-care routines.",
                ),
                _buildDisorderCard(
                  title: "Post-Traumatic Stress Disorder (PTSD)",
                  description:
                      "PTSD may develop after experiencing or witnessing a traumatic event. "
                      "Individuals may have flashbacks, nightmares, or strong emotional reactions to reminders of the trauma. "
                      "Therapy and stress management techniques are key parts of recovery.",
                ),
                _buildDisorderCard(
                  title: "Obsessive-Compulsive Disorder (OCD)",
                  description:
                      "OCD involves repetitive thoughts (obsessions) and behaviors (compulsions) that a person feels driven to perform. "
                      "These behaviors are attempts to reduce anxiety but can disrupt daily life. "
                      "Treatment often includes therapy such as exposure and response prevention (ERP).",
                ),
                _buildDisorderCard(
                  title: "Schizophrenia Spectrum Disorders",
                  description:
                      "Schizophrenia affects perception, thinking, and behavior. "
                      "It can cause hallucinations, delusions, or disorganized thoughts. "
                      "Ongoing treatment with medication, therapy, and community support is essential.",
                ),
                _buildDisorderCard(
                  title: "Eating Disorders",
                  description:
                      "Eating disorders involve unhealthy relationships with food, body image, or self-perception. "
                      "These may include restrictive eating, bingeing, or purging behaviors. "
                      "Recovery includes therapy, nutritional counseling, and emotional support.",
                ),
                _buildDisorderCard(
                  title: "Personality Disorders",
                  description:
                      "Personality disorders are long-term patterns of thinking and behavior that differ from societal expectations. "
                      "They can affect relationships, self-image, and emotions. "
                      "Psychotherapy is the main form of treatment, focusing on healthy coping and self-awareness.",
                ),

                const SizedBox(height: 30),
                const Text(
                  "Learning about these conditions helps reduce stigma and build empathy. "
                  "Understanding is the first step toward offering real support and compassion.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Custom smooth expanding card
  Widget _buildDisorderCard({
    required String title,
    required String description,
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
          borderRadius: BorderRadius.circular(25),
          // border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.15),
          //     blurRadius: 4,
          //     offset: const Offset(1, 2),
          //   ),
          // ],
        ),
        child: Column(
          children: [
            /// Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
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

            /// Smooth expanding text
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.justify,
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
