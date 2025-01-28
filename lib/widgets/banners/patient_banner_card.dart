import 'package:flutter/material.dart';
import 'package:armstrong/patient/models/widgets/banner_model.dart';

class BannerCard extends StatelessWidget {
  final CarouselItem item;

  const BannerCard({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      key: key, // Key to identify each unique card
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(screenWidth * 0.05), // 5% of screen width for corner radius
        image: item.image.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Center(
        child: Text(
          item.text,
          style: TextStyle(
            fontSize: screenWidth * 0.06, // Responsive font size (6% of screen width)
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
