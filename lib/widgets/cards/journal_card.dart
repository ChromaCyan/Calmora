import 'package:flutter/material.dart';
import 'package:armstrong/patient/screens/dashboard/journal_page/journal_page.dart';
import 'package:armstrong/config/colors.dart';

class JournalSection extends StatelessWidget {
  const JournalSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, 
      height: 140, 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: orangeContainer,  
        image: DecorationImage(
          image: AssetImage('images/splash/image1.png'), 
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
            'Daily Journal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Log Your Mood',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
