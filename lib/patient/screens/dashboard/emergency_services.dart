import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.6),
        elevation: 0,
        title: Text(
          "Emergency Services",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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

          /// Foreground content
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              kToolbarHeight + 32,
              16,
              16,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    "You Are Not Alone",
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    "If you or someone you know is struggling, these hotlines are available to provide help and support.",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: theme.colorScheme.onBackground.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Divider(color: Colors.grey.shade600),
                  const SizedBox(height: 16),

                  // Section title
                  Text(
                    "Mental Health Hotlines (PH)",
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hotline list
                  _buildHotlineTile(
                    context,
                    icon: Icons.phone,
                    title: "Philippines Mental Health Association",
                    number: "(02) 8821 4958",
                    color: Colors.green,
                  ),
                  Divider(color: Colors.grey.shade600),
                  _buildHotlineTile(
                    context,
                    icon: Icons.support_agent,
                    title: "DOH Mental Health Crisis Hotline",
                    number: '0917-899-8727',
                    color: Colors.blue,
                  ),
                  Divider(color: Colors.grey.shade600),
                  _buildHotlineTile(
                    context,
                    icon: Icons.heart_broken,
                    title: "In Touch Community Services",
                    number: "(02) 8893-1903",
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Hotline Row
  Widget _buildHotlineTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String number,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.75),
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
