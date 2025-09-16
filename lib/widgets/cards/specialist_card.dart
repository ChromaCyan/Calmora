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
    return firstWord.length > 10 ? "${firstWord.substring(0, 10)}..." : firstWord;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth = screenWidth * 0.4;
    if (screenWidth > 600) cardWidth = screenWidth * 0.25;
    cardWidth = cardWidth.clamp(160, 250);

    // return GestureDetector(
    //   onTap: onTap,
    //   child: Container(
    //     width: cardWidth,
    //     decoration: BoxDecoration(
    //       color: Colors.white.withOpacity(0.05),
    //       borderRadius: BorderRadius.circular(20),
    //       border: Border.all(color: Colors.white.withOpacity(0.1)),
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black.withOpacity(0.1),
    //           blurRadius: 10,
    //           offset: const Offset(0, 4),
    //         ),
    //       ],
    //     ),
    //     padding: const EdgeInsets.all(12),
    //     child: Column(
    //       children: [
    //         ClipRRect(
    //           borderRadius: BorderRadius.circular(14),
    //           child: AspectRatio(
    //             aspectRatio: 1,
    //             child: (specialist.profileImage != null &&
    //                     specialist.profileImage!.isNotEmpty)
    //                 ? Image.network(
    //                     specialist.profileImage!,
    //                     fit: BoxFit.cover,
    //                     errorBuilder: (context, error, stackTrace) {
    //                       return Image.asset(
    //                         'images/no_profile.png',
    //                         fit: BoxFit.cover,
    //                       );
    //                     },
    //                   )
    //                 : Image.asset(
    //                     'images/no_profile.png',
    //                     fit: BoxFit.cover,
    //                   ),
    //           ),
    //         ),
    //         const SizedBox(height: 8),
    //         Text(
    //           formatName("${specialist.firstName} ${specialist.lastName}"),
    //           style: TextStyle(
    //             fontSize: 18,
    //             fontWeight: FontWeight.bold,
    //             color: Colors.white.withOpacity(0.95),
    //           ),
    //           textAlign: TextAlign.center,
    //         ),
    //         const SizedBox(height: 4),
    //         Text(
    //           specialist.specialization,
    //           style: TextStyle(
    //             fontSize: 14,
    //             color: Colors.white.withOpacity(0.7),
    //           ),
    //           textAlign: TextAlign.center,
    //           maxLines: 1,
    //           overflow: TextOverflow.ellipsis,
    //         ),
    //         const SizedBox(height: 4),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Icon(Icons.location_on,
    //                 size: 16, color: Colors.blueAccent.withOpacity(0.8)),
    //             const SizedBox(width: 4),
    //             Flexible(
    //               child: Text(
    //                 specialist.location ?? 'Unknown',
    //                 style: TextStyle(
    //                   fontSize: 13,
    //                   color: Colors.white.withOpacity(0.6),
    //                 ),
    //                 textAlign: TextAlign.center,
    //                 maxLines: 1,
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //             ),
    //           ],
    //         )
    //       ],
    //     ),
    //   ),
    // );
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cardWidth,
        height: 220,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              (specialist.profileImage != null &&
                      specialist.profileImage!.isNotEmpty)
                  ? Image.network(
                      specialist.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'images/no_profile2.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      'images/no_profile2.png',
                      fit: BoxFit.cover,
                    ),

              // Gradient overlay
              // Gradient overlay (bottom only)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120, // Adjust this height as needed
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Text content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      formatName("${specialist.firstName} ${specialist.lastName}"),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialist.specialization,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            specialist.location ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
