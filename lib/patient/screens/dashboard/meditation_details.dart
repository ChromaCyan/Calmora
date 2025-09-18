import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'dart:ui';

class MindfulMeditation extends StatelessWidget {
  const MindfulMeditation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/login_bg_image.png',
            fit: BoxFit.fill,
          ),
          Container(
            color: theme.colorScheme.surface
                .withOpacity(0.6), // match transparency
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // match blur
              child: const SizedBox.expand(),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/meditation2.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "What is Meditation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Before we begin the Meditation Exercise Guide let us first learn what meditation is. Meditation is a practice that involves focusing or clearing your mind using a combination of mental and physical techniques. This a way for the mind to calm and relax your mind that can reduce mental pain like stress and anxiety.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Steps to Begin:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      _boldBullet("Find a quiet and comfortable space to meditate"),
                      _normal(
                          " - this is to avoid distractions and also makes it easier to calm the mind.\n\n"),
                      _boldBullet("Find the right position"),
                      _normal(
                          " - You can meditate sitting, lying down, standing, or even walking. For most beginners, sitting in a comfortable upright posture will be the easiest way to get started.\n\n"),
                      _boldBullet("Set a Time Limit"),
                      _normal(
                          " - It is important to pick a time you can commit to daily. This helps to build a consistent routine and make meditation a habit.\n\n"),
                      _boldBullet(
                          "Close your eyes and Take a Deep Breath Exercise"),
                      _normal(
                          " - This step is where you take deep breaths and exhale, feeling each breath to relax the mind and get rid of any distractions.\n\n"),
                      _boldBullet("Body Relaxation"),
                      _normal(
                          " - While doing the deep breathing exercise, let your body relax with each breath you take and allow yourself to drift and wonder.\n\n"),
                      _boldBullet("You find your mind has wandered"),
                      _normal(
                          " - This means exactly what it says: your attention will leave the breath and wander to other places. This can last any amount of time, and when you notice it, simply return your attention to the breath.\n\n"),
                      _boldBullet("Returning Back after meditation"),
                      _normal(
                          " - After your mind has wandered and you return, take a moment to notice any sounds in the environment. Notice how your body feels right now. Notice your thoughts and emotions.\n"),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "You focus your attention, your mind wanders, you bring it back, and you try to do it as kindly as possible (as many times as you need to).",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'images/meditation3.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Here are some Benefits of Meditation:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      _boldBullet("Reduces Stress"),
                      _normal(
                          " - Stress reduction is one of the most common reasons people try meditation.\n\n"),
                      _boldBullet("Controls Anxiety"),
                      _normal(
                          " - Meditation can reduce stress levels, which translates to less anxiety.\n\n"),
                      _boldBullet("Supports emotional health"),
                      _normal(
                          " - Some forms of meditation can lead to improved self-image and a more positive outlook on life.\n\n"),
                      _boldBullet("Enhances self-awareness"),
                      _normal(
                          " - Some forms of meditation may help you develop a stronger understanding of yourself, helping you grow into your best self.\n\n"),
                      _boldBullet("Lengthens Attention Span"),
                      _normal(
                          " - Focused attention meditation is like weightlifting for your attention span. It helps increase your attention span’s strength and endurance.\n"),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "These are just some of the benefits of meditation and there are more benefits u can get from meditation what's important is to meditate regularly and it will help heal and clear your mind",
                  style: TextStyle(fontSize: 16),
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
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  );
}

TextSpan _normal(String text) {
  return TextSpan(
    text: text,
    style: TextStyle(fontSize: 16),
  );
}
