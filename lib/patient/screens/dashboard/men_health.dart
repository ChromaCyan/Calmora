import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';
import 'package:google_fonts/google_fonts.dart';

class MentalHealthAwarenessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(title: "Mental Health Awareness"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                "Mental Health Matters!",
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: 25),
            Divider(
              thickness: 2, // Adjust thickness as needed
              color: Colors.grey, // Adjust color as needed
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 30, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "It's okay to seek help.",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground, // Dynamic color
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Recognizing when you need support is a sign of strength. Don't hesitate to reach out to a friend or a professional.",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), // Dynamic color with opacity
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 1, // Adjust thickness as needed
              color: Colors.grey.shade700, // Adjust color as needed
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.group, size: 30, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "You are part of a community.",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground, // Dynamic color
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Every people face similar challenges. Sharing your experiences can foster connection and understanding.",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), // Dynamic color with opacity
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 1, // Adjust thickness as needed
              color: Colors.grey.shade700, // Adjust color as needed
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble, size: 30, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Communication is key.",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground, // Dynamic color
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Talking about your feelings can help you process them. Consider journaling or discussing with someone you trust.",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), // Dynamic color with opacity
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Divider(
              thickness: 1, // Adjust thickness as needed
              color: Colors.grey.shade700, // Adjust color as needed
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.self_improvement, size: 30, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Self-care is essential.",
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground, // Dynamic color
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Engaging in activities that bring you joy and relaxation is crucial. Whether it's exercise, hobbies, or spending time in nature, make time for yourself.",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
