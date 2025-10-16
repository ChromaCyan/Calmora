// import 'package:flutter/material.dart';

// class HotlineCard extends StatelessWidget {
//   // final String title;
//   // final String subtitle;
//   final String? imagePath;      // Local asset image path
//   final String? imageUrl;
//   final VoidCallback? onTap;

//   const HotlineCard({
//     Key? key,
//     // required this.title,
//     // required this.subtitle,
//     this.imagePath,
//     this.imageUrl,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Widget? leadingImage;

//     if (imagePath != null) {
//       leadingImage = ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Image.asset(
//           imagePath!,
//           width: 48,
//           height: 48,
//           fit: BoxFit.cover,
//         ),
//       );
//     } else if (imageUrl != null) {
//       leadingImage = ClipRRect(
//         borderRadius: BorderRadius.circular(8),
//         child: Image.network(
//           imageUrl!,
//           width: 48,
//           height: 48,
//           fit: BoxFit.cover,
//         ),
//       );
//     }

//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               if (leadingImage != null) leadingImage,
//               if (leadingImage != null) const SizedBox(width: 16),
//               // Expanded(
//               //   child: Column(
//               //     crossAxisAlignment: CrossAxisAlignment.start,
//               //     children: [
//               //       Text(
//               //         title,
//               //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
//               //               fontWeight: FontWeight.bold,
//               //             ),
//               //       ),
//               //       const SizedBox(height: 4),
//               //       Text(
//               //         subtitle,
//               //         style: Theme.of(context).textTheme.bodyMedium,
//               //       ),
//               //     ],
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HotlineCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const HotlineCard({
    Key? key,
    required this.imagePath,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Ensures it's a perfect square
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100), // Fully circular
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
