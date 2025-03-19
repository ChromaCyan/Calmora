import 'package:armstrong/models/user/specialist.dart';
import 'package:flutter/material.dart';

class SpecialistCard extends StatelessWidget {
  final Specialist specialist;
  final VoidCallback onTap;

  const SpecialistCard(
      {Key? key, required this.specialist, required this.onTap})
      : super(key: key);

  String formatName(String name) {
    List<String> words = name.split(" ");
    String firstWord = words.isNotEmpty ? words[0] : "";
    return firstWord.length > 7 ? "${firstWord.substring(0, 7)}..." : firstWord;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double nameFontSize = screenWidth * 0.045;
    double specializationFontSize = screenWidth * 0.035;
    double locationFontSize = screenWidth * 0.032;

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
                    child: Image.network(
                      specialist.profileImage ??
                          'images/armstrong_transparent.png', 
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
                      fontSize: (nameFontSize * MediaQuery.of(context).size.width / 375).clamp(16, 22), // Adjust size based on screen width
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
                      fontSize: (specializationFontSize * MediaQuery.of(context).size.width / 375).clamp(14, 18), // Adjust size based on screen width
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1, 
                    overflow:
                        TextOverflow.ellipsis, 
                  ),
                ),
                const SizedBox(height: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on, 
                      color: Colors.blue, 
                      size: (18 * MediaQuery.of(context).size.width / 375).clamp(16, 24), // Make icon size responsive
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        specialist.location ?? 'Unknown Location',
                        style: TextStyle(
                          fontSize: (locationFontSize * MediaQuery.of(context).size.width / 375).clamp(12, 16), // Adjust size based on screen width
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
