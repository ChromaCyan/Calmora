import 'package:armstrong/patient/screens/journal/journal_screen.dart';
import 'package:flutter/material.dart';

class JournalSection extends StatelessWidget {
  const JournalSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Set maximum height based on screen height to avoid overflow
    double sectionHeight = screenHeight * 0.2; // 20% of screen height, you can tweak this

    return Container(
      width: double.infinity,
      height: sectionHeight,
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width for padding
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        image: const DecorationImage(
          image: AssetImage('images/splash/image1.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Daily Journal',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white, // Always light-colored
              fontSize: screenWidth * 0.05, // Adaptive font size based on screen width
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center, // Center text
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return JournalPage();  // Destination page
                  },
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    // Fade transition
                    var slideAnimation = Tween<Offset>(
                      begin: Offset(1.0, 0.0), // Slide from the right
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
                    return SlideTransition(position: slideAnimation, child: child);
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.015, // 1.5% of screen height for padding
                horizontal: screenWidth * 0.1,  // 10% of screen width for padding
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
            ),
            child: Text(
              'Log Your Mood',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: screenWidth * 0.045, // Adaptive font size based on screen width
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
