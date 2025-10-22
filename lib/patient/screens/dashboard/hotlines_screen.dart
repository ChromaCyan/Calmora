import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class HotlinesScreen extends StatelessWidget {
  const HotlinesScreen({super.key});

  final List<Map<String, String>> hotlines = const [
    {
      "name": "Suicide Crisis Lines",
      "phone": "+639178001123",
      "network": "Globe",
    },
    {
      "name": "National Center for Mental Health (NCMH)",
      "phone": "+639178998727",
      "network": "Globe",
    },
    {
      "name": "National Center for Mental Health (NCMH)",
      "phone": "+639190571553",
      "network": "Smart",
    },
    {
      "name": "HopeLine",
      "phone": "+639175584673",
      "network": "Globe",
    },
    {
      "name": "Hopeline",
      "phone": "+639188734673",
      "network": "Smart",
    },
  ];

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch $phoneNumber');
    }
  }

  Future<void> _confirmAndLaunchPhone(
    BuildContext context,
    String name,
    String phoneNumber,
  ) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🧠 Call Icon
                    Text(
                      'Call $name?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Description
                    Text(
                      'You’ll be redirected to your Phone app with:\n\n📞 $phoneNumber',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 0.6),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              foregroundColor: scheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: scheme.error,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 0.8,
                          height: 48,
                          color: scheme.outlineVariant.withOpacity(0.3),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: scheme.primary,
                            ),
                            child: Text(
                              "Proceed",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true) {
      _launchPhone(phoneNumber);
    }
  }

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
              color: theme.colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Emergency Hotlines",
          style: TextStyle(
            color: theme.colorScheme.onPrimaryContainer,
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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cover Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'images/hotline_cover_image.png', // replace with your image asset path
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Text
                  Text(
                    'In case of certain emergencies where you might need urgent help. Here are some of hotlines that operates here in the Philippines whom you can contact and reach out for, to seek support.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 35),
                  Text(
                    "Disclaimer",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "•  Please be aware that making a call may reduce your load depending how long the call lasted.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    // textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Hotline Cards
                  ...hotlines.map((hotline) {
                    return Card(
                      color: theme.colorScheme.surface.withOpacity(0.6),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: Colors.green,
                        ),
                        title: Text(
                          hotline["name"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        subtitle: Text(
                          '${hotline["phone"]!} • ${hotline["network"] ?? "Unknown Network"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => _confirmAndLaunchPhone(
                          context,
                          hotline["name"]!,
                          hotline["phone"]!,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
