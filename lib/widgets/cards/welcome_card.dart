import 'package:flutter/material.dart';

// Welcome Section Widget
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({Key? key}) : super(key: key);

 @override
Widget build(BuildContext context) {
  // Get the screen width
  final screenWidth = MediaQuery.of(context).size.width;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Use Flexible to prevent overflow
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Remember, strength is not just physical, mental resilience is power.",
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 15 : 18, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
                maxLines: 2, // Limit to 2 lines
              ),
              // Uncomment if you want to add this text
              // SizedBox(height: 10),
              // Text(
              //   'How are you feeling today?',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.grey,
              //   ),
              // ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('images/icons/relax.png'),
        ),
      ],
    ),
  );
}
}