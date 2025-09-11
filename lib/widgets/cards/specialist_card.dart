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

    // return GestureDetector(
    //   onTap: onTap,
    //   child: Card(
    //     elevation: 0,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //     child: Padding(
    //       padding: const EdgeInsets.all(12),
    //       child: ConstrainedBox(
    //         constraints: const BoxConstraints(
    //           minHeight: 80,
    //         ),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min, 
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             ClipRRect(
    //               borderRadius: BorderRadius.circular(10),
    //               child: AspectRatio(
    //                 aspectRatio: 5 / 5, 
    //                 child: Image.network(
    //                   specialist.profileImage ??
    //                       'images/armstrong_transparent.png', 
    //                   fit: BoxFit.cover,
    //                 ),
    //               ),
    //             ),

    //             const SizedBox(height: 5),

    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //               child: Text(
    //                 formatName(
    //                     "${specialist.firstName} ${specialist.lastName}"),
    //                 style: TextStyle(
    //                   fontSize: (nameFontSize * MediaQuery.of(context).size.width / 375).clamp(16, 22), // Adjust size based on screen width
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //             ),
    //             const SizedBox(height: 2),

    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //               child: Text(
    //                 specialist.specialization,
    //                 style: TextStyle(
    //                   fontSize: (specializationFontSize * MediaQuery.of(context).size.width / 375).clamp(14, 18), // Adjust size based on screen width
    //                   color: Colors.grey[600],
    //                 ),
    //                 textAlign: TextAlign.center,
    //                 maxLines: 1, 
    //                 overflow:
    //                     TextOverflow.ellipsis, 
    //               ),
    //             ),
    //             const SizedBox(height: 2),

    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   Icons.location_on, 
    //                   color: Colors.blue, 
    //                   size: (18 * MediaQuery.of(context).size.width / 375).clamp(16, 24), // Make icon size responsive
    //                 ),
    //                 const SizedBox(width: 4),
    //                 Expanded(
    //                   child: Text(
    //                     specialist.location ?? 'Unknown Location',
    //                     style: TextStyle(
    //                       fontSize: (locationFontSize * MediaQuery.of(context).size.width / 375).clamp(12, 16), // Adjust size based on screen width
    //                       color: Colors.grey[600],
    //                     ),
    //                     textAlign: TextAlign.center,
    //                     maxLines: 2, 
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.45,
        height: 250, // adjust to fit design
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.15),
          //     spreadRadius: 2,
          //     blurRadius: 8,
          //     offset: const Offset(0, 4),
          //   ),
          // ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background profile image
              Image.network(
                specialist.profileImage ??
                    'images/calmora_circle_crop.png',
                fit: BoxFit.cover,
              ),

              // Dark gradient overlay
              // Container(
              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.bottomCenter,
              //       end: Alignment.topCenter,
              //       colors: [
              //         Colors.black45,     // strong black at the bottom
              //         Colors.transparent, // fades to transparent at the top
              //       ],
              //     ),
              //     borderRadius: BorderRadius.all(Radius.circular(15))
              //   ),
              // ),
              Align(
  alignment: Alignment.bottomCenter,
  child: Container(
    height: 120, // 👈 adjust this
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black45,
          Colors.transparent,
        ],
      ),
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(15),
      ),
    ),
  ),
),



              // Overlaying contents
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        "${specialist.firstName} ${specialist.lastName}",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Specialization
                      Text(
                        specialist.specialization,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Location row
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              specialist.location ?? 'Unknown Location',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
