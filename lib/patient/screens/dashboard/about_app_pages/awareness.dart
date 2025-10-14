import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MentalHealthAwarenessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
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
          "For Awareness",
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
            fit: BoxFit.cover,
          ),

          /// Frosted blur overlay
          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          /// Page content
          SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 32, 16, 16),
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height -
          (kToolbarHeight + 32 + 16), // available height
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Filipinos’s Mental Health Matters",
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),

          // Your big container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.15),
              //     blurRadius: 8,
              //     offset: const Offset(0, 4),
              //   )
              // ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTip(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: "It's okay to seek help.",
                  message:
                      "Recognizing when you need support is a sign of strength. Don't hesitate to reach out to a friend or a professional.",
                  iconColor: Colors.amber,
                ),
                Divider(color: Colors.grey.shade600),
                _buildTip(
                  context,
                  icon: Icons.group,
                  title: "You are part of a community.",
                  message:
                      "Many Filipinos face similar challenges. Sharing your experiences can foster connection and understanding.",
                  iconColor: Colors.green,
                ),
                Divider(color: Colors.grey.shade600),
                _buildTip(
                  context,
                  icon: Icons.chat_bubble,
                  title: "Communication is key.",
                  message:
                      "Talking about your feelings can help you process them. Consider journaling or discussing with someone you trust.",
                  iconColor: Colors.teal,
                ),
                Divider(color: Colors.grey.shade600),
                _buildTip(
                  context,
                  icon: Icons.self_improvement,
                  title: "Self-care is essential.",
                  message:
                      "Engaging in activities that bring you joy and relaxation is crucial. Whether it's exercise, hobbies, or spending time in nature, make time for yourself.",
                  iconColor: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),

        ],
      ),
    );
  }

  /// Reusable tip row
  Widget _buildTip(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    Color? iconColor, // ✅ new optional param
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28,
            color: iconColor ?? theme.colorScheme.primary, // ✅ use custom color
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: theme.colorScheme.onBackground.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
