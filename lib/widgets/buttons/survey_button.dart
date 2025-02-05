import 'package:armstrong/config/colors.dart';
import 'package:armstrong/patient/screens/survey/questions_screen.dart';
import 'package:flutter/material.dart';

class QuickTestButton extends StatelessWidget {
  const QuickTestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: buttonColor, 
        image: DecorationImage(
          image: AssetImage('/images/splash/image2.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3), 
            BlendMode.darken,
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Take a quick test about your mental health',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuestionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orangeContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Accept',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
