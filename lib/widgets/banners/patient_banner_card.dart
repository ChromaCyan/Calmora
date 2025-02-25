import 'package:flutter/material.dart';
import 'package:armstrong/models/banner_model.dart';

class BannerCard extends StatelessWidget {
  final CarouselItem item;

  const BannerCard({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      key: key, 
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(screenWidth * 0.05), 
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
            fontSize: screenWidth * 0.06, 
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
