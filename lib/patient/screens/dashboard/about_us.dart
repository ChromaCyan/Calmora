import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main Content with Padding
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Our App
                  Text(
                    "About Our App",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Container with App Logo & Description
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Column(
                      children: [
                        // App Logo
                        Image.asset(
                          "images/armstrong_transparent.png", // Replace with actual image path
                          height: 250,
                          width: 250,
                        ),
                        SizedBox(height: 10),

                        // Description
                        Text(
                          "Armstrong is a mental health app designed for adult male who are deeply seeking for mental health support. "
                          "From the phrase 'a Helping Hand' combined with the brute strength of men, our taeam came up with the name 'Armstrong' to symbolize using the strength of men by offering a hand for another man who's in need."
                          "",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  // Divider to separate sections
                  Divider(
                    thickness: 2, // Adjust thickness as needed
                    color: Colors.grey, // Adjust color as needed
                  ),

                  SizedBox(height: 20),

                  // Our Mission
                  Text(
                    "Our Mission",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Text(
                      "To build user-friendly applications to give men a safe space for their comfort during tough times. "
                      "Provide them the resources they need to help them and guide to further improve their mental health and for them to potentially improve their lifestyle. "
                      "Allowing men to join a supportive community for them to share their stories and other things through typing words, and to reach out to licensed mental health professionals to seek further support.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Divider to separate sections
                  Divider(
                    thickness: 2, // Adjust thickness as needed
                    color: Colors.grey, // Adjust color as needed
                  ),

                  SizedBox(height: 20),

                  // Our Vision
                  Text(
                    "Our Vision",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Text(
                      "Armstrong aims to reduce and contribute in fully eliminating the effects of stigma revolving around men's mental health. "
                      "Reminding the world that men can be soft or feminine, and we must not shame them when they show their vulnerabilities just because 'they are men'.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Divider to separate sections
                  Divider(
                    thickness: 2, // Adjust thickness as needed
                    color: Colors.grey, // Adjust color as needed
                  ),

                  SizedBox(height: 30),

                  // Our Team
                  Text(
                    'Our Team',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Team Member Part

                  // Project Manager
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/john_doe.jpg'), // Replace with actual image
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Oliver, Ferrer',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Role: Project Manager",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Quote: If they can do it, so can you.",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // System Analyst and Frontend Developer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/john_doe.jpg'), // Replace with actual image
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Genghis, Bautista',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Role: System Analyst and Frontend Developer",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Quote: The past is history, the future is a mistery, even if your life is so misery, remember that hope can still be a victory.",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // System Integrator and FullStack Developer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/john_doe.jpg'), // Replace with actual image
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Josh Brian, Bugarin',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Role: System Integrator and Fullstack Developer",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Quote: Always stand back up whenever you fall, no matter what.",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // System Integrator, Frontend Developer and Backend Developer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/john_doe.jpg'), // Replace with actual image
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Raven, Caguioa',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Role: System Integrator and Frontend Developer",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Quote: Never be easily affected by other's criticism, for they are just words.",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Dumbell
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/john_doe.jpg'), // Replace with actual image
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marion, Queñano',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Role: System Analyst",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                              Divider(
                                thickness: 1, // Adjust thickness as needed
                                color: Colors.grey, // Adjust color as needed
                              ),
                              Text(
                                "Quote: If an opportunity opens, do not hesitate to grab it.",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                                    // Divider to separate sections
                  Divider(
                    thickness: 2, // Adjust thickness as needed
                    color: Colors.grey, // Adjust color as needed
                  ),

                  SizedBox(height: 20),

                  // Gallery Section
                  Text(
                    'Gallery',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Container for the Gallery
                  // First Gallery Item
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        SizedBox(
                            height: 100,
                            width: 130,
                          child: Image.asset(
                            'assets/gallery1.jpg', // Replace with actual image
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last sem exhibit?',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'What to put here?',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  // Second Gallery Item
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Behind the scene?',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'What to put here',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                            height: 100,
                            width: 130,
                          child: Image.asset(
                            'assets/gallery2.jpg', // Replace with actual image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: boxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center everything
                      children: [
                        // Row with Two Images
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 140, // Adjust as needed
                              height: 100,
                              child: Image.asset(
                                'assets/gallery3_1.jpg', // Replace with actual image
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10), // Spacing between images
                            SizedBox(
                              width: 140,
                              height: 100,
                              child: Image.asset(
                                'assets/gallery3_2.jpg', // Replace with actual image
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10), // Space between images and text

                        // Description Text Below
                        Text(
                          'Workshop Pic?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center, // Center align text
                        ),
                        SizedBox(height: 5),
                        Text(
                          'What to put here?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 50),
                ],
              ),
            ),

            // Footer (Outside the Padded Content)
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.07, // Adjust this percentage as needed
              constraints: BoxConstraints(
                minHeight: 50, // Minimum height (won't shrink below this)
                maxHeight: 70, // Maximum height (won't grow beyond this)
              ),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green),
              child: Center(
                child: Text(
                  '© 2025 Armstrong, All Rights Reserved.',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BoxDecoration for uniform container styling
  BoxDecoration boxDecoration() {
    return BoxDecoration(
      // color: Colors.grey[200],
      // borderRadius: BorderRadius.circular(10),
    );
  }
}
