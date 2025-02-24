import 'package:flutter/material.dart';

// Welcome Section Widget
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('images/splash/logo_placeholder.png'),
          ),
        ],
      ),
    );
  }
}