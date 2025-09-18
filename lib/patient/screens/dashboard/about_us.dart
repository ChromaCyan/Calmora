import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: theme.colorScheme.surface.withOpacity(0.6),
        // elevation: 0,
        // title: Text(
        //   "About Us",
        //   style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        // ),
        // centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background image
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.fill,
          ),

          /// Blur + overlay
          /// Blur + overlay
          Container(
            color: theme.colorScheme.surface
                .withOpacity(0.6), // match transparency
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // match blur
              child: const SizedBox.expand(),
            ),
          ),

          /// Foreground content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.transparent, // match transparency
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // BoxShadow(
                        //   color: Colors.black
                        //       .withOpacity(0.15), // softer like other page
                        //   blurRadius: 8,
                        //   offset: const Offset(0, 4),
                        // ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// About Section
                        Text(
                          "What is Calmora?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        /// ✅ Centered Image
                        Center(
                          child: Image.asset(
                            "images/calmora_circle_crop.png",
                            height: 200,
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          "Calmora is a mental health app designed for Filipinos who are seeking support for their mental well-being. "
                          "From the phrase 'a Helping Hand' combined with the resilience of Filipinos, our team came up with the name 'Calmora' "
                          "to symbolize using our collective strength by offering a hand to fellow Filipinos in need.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade400),

                        /// Mission
                        const SizedBox(height: 20),
                        Text(
                          "Our Mission",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "To build user-friendly applications that give Filipinos a safe space for comfort during tough times. "
                          "Provide them with the resources they need to improve their mental health and guide them toward a healthier lifestyle. "
                          "And reach out to licensed mental health professionals for further support.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade400),

                        /// Vision
                        const SizedBox(height: 20),
                        Text(
                          "Our Vision",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Calmora aims to reduce and contribute in fully eliminating the effects of stigma revolving around Filipinos’ mental health. "
                          "Reminding the world that Filipinos can express their emotions and vulnerabilities, and we must not shame them when they show their true feelings just because of cultural expectations.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade400),

                        /// Team
                        const SizedBox(height: 20),
                        Text(
                          "Our Team",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _buildTeamMember(
                          "John Oliver, Ferrer",
                          "Project Manager",
                          "If they can do it, so can you.",
                          "images/members_pfp/oliver.jpg",
                        ),
                        _buildTeamMember(
                          "Genghis, Bautista",
                          "System Analyst and Frontend Developer",
                          "Healing comes in steps, and with time, it grows.",
                          "images/members_pfp/genghis.jpg",
                        ),
                        _buildTeamMember(
                          "Josh Brian, Bugarin",
                          "System Integrator and Fullstack Developer",
                          "Always stand back up whenever you fall, no matter what.",
                          "images/members_pfp/josh.jpg",
                        ),
                        _buildTeamMember(
                          "Raven, Caguioa",
                          "System Integrator and Frontend Developer",
                          "Never be easily affected by other's criticism, for they are just words.",
                          "images/members_pfp/raven.jpg",
                        ),
                        _buildTeamMember(
                          "Marion, Queñano",
                          "System Analyst",
                          "If an opportunity opens, do not hesitate to grab it.",
                          "images/members_pfp/marion.jpg",
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              /// Footer
              // Container(
              //   width: double.infinity,
              //   height: MediaQuery.of(context).size.height * 0.07,
              //   padding: const EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //     color: theme.colorScheme.surface.withOpacity(0.9),
              //   ),
              //   child: Center(
              //     child: Text(
              //       "© 2025 Calmora, All Rights Reserved.",
              //       style: GoogleFonts.lato(
              //         fontSize: 14,
              //         color: theme.brightness == Brightness.dark
              //             ? Colors.white
              //             : Colors.black,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper: Team member card
  // Widget _buildTeamMember(
  //     String name, String role, String quote, String imagePath) {
  //   return Builder(
  //     builder: (context) {
  //       final theme = Theme.of(context);
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 16),
  //         padding: const EdgeInsets.all(19),
  //         decoration: BoxDecoration(
  //           color: theme.colorScheme.surface.withOpacity(0.5), // ✅ theme-aware
  //           borderRadius: BorderRadius.circular(20),
  //           // border: Border.all(
  //           //   color: Colors.white.withOpacity(0.9)
  //           // ),
  //         ),
  //         child: Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 40,
  //               backgroundImage: AssetImage(imagePath),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     name,
  //                     style: GoogleFonts.lato(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const Divider(color: Colors.grey),
  //                   Text(
  //                     "Role: $role",
  //                     style: GoogleFonts.lato(fontSize: 14),
  //                   ),
  //                   const Divider(color: Colors.grey),
  //                   Text(
  //                     "Quote: $quote",
  //                     style: GoogleFonts.lato(fontSize: 14),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
Widget _buildTeamMember(
  String name,
  String role,
  String quote,
  String imagePath,
) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ so it grows tall
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    // softWrap: true,              // ✅ allows wrapping
                    // overflow: TextOverflow.visible, // ✅ no ellipsis
                  ),
                  const Divider(color: Colors.grey),
                  Text(
                    "Role: $role",
                    style: TextStyle(fontSize: 14),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const Divider(color: Colors.grey),
                  Text(
                    "Quote: $quote",
                    style: TextStyle(fontSize: 14),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

}
