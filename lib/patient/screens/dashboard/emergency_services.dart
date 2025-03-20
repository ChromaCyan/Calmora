import 'package:flutter/material.dart';
import 'package:armstrong/widgets/navigation/appbar.dart';

class EmergencyServicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: UniversalAppBar(title: "Emergency Services"),
      body: SingleChildScrollView(  // Allows scrolling if the screen is small
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Responsive horizontal padding
            vertical: screenHeight * 0.02,  // Responsive vertical padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "You Are Not Alone",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,  // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),  // Responsive spacing
              Text(
                "If you or someone you know is struggling, these hotlines are available to provide help and support.",
                style: TextStyle(
                  fontSize: screenWidth * 0.04, 
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Divider(thickness: 1, color: Colors.grey.shade700),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Mental Health Hotlines (PH)",
                style: TextStyle(
                  fontSize: screenWidth * 0.05, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              
              HotlineTile(icon: Icons.phone, title: "Philippines Mental Health Association", number: "(02) 8821 4958", color: Colors.green),
              HotlineTile(icon: Icons.support_agent, title: "DOH Mental Health Crisis Hotline", number: '0917-899-8727', color: Colors.blue),
              HotlineTile(icon: Icons.heart_broken, title: "In Touch Community Services", number: "(02) 8893-1903", color: Colors.redAccent),
              SizedBox(height: screenHeight * 0.02),
            // Text(
            //   'Clinic Location',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 10),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(10),
            //   child: Image.asset(
            //     'assets/images/clinic_location.png', // Replace with your screenshot
            //     fit: BoxFit.cover,
            //     height: 200,
            //     width: double.infinity,
            //   ),
            // ),
            // SizedBox(height: 10),
            // Text(
            //   '123 Main Street, YourCity, Philippines',
            //   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            // ),
            ],
          ),
        ),
      ),
    );
  }
}

class HotlineTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String number;
  final Color color;

  HotlineTile({required this.icon, required this.title, required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListTile(
      leading: Icon(icon, color: color, size: screenWidth * 0.08), // Responsive icon size
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045, 
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        number,
        style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[500]),
      ),
    );
  }
}
