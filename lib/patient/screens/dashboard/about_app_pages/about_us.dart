import 'dart:ui';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
          "About Calmora",
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
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.fill,
          ),

          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "What is Calmora?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

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
            ],
          ),
        ],
      ),
    );
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
