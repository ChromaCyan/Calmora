import 'package:flutter/material.dart';
import 'package:armstrong/models/user/specialist.dart';

class SpecialistCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;

  const SpecialistCard({
    Key? key,
    required this.specialist,
    required this.onTap,
  }) : super(key: key);

  String formatName(String name) {
    List<String> words = name.split(" ");
    String firstWord = words.isNotEmpty ? words[0] : "";
    return firstWord.length > 7 ? "${firstWord.substring(0, 7)}..." : firstWord;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = screenWidth * 0.4;
    if (screenWidth > 600) cardWidth = screenWidth * 0.25;
    cardWidth = cardWidth.clamp(160, 250);

    const nameFontSize = 18.0;
    const specializationFontSize = 16.0;
    const locationFontSize = 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 80,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 5 / 5,
                    child: (specialist.profileImage != null &&
                            specialist.profileImage!.isNotEmpty)
                        ? Image.network(
                            specialist.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'images/no_profile.png', 
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'images/no_profile.png', 
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    formatName(
                        "${specialist.firstName} ${specialist.lastName}"),
                    style: TextStyle(
                      fontSize: (nameFontSize * screenWidth / 375).clamp(16, 22),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    specialist.specialization,
                    style: TextStyle(
                      fontSize: (specializationFontSize * screenWidth / 375)
                          .clamp(14, 18),
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue,
                      size: (18 * screenWidth / 375).clamp(16, 24),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        specialist.location ?? 'Unknown Location',
                        style: TextStyle(
                          fontSize: (locationFontSize * screenWidth / 375)
                              .clamp(12, 16),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
  }
}
