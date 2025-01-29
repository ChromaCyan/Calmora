import 'dart:async';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/banners/patient_banner_card.dart';
import 'package:armstrong/patient/models/widgets/banner_model.dart';
import 'package:armstrong/config/colors.dart';

class HealthAdviceSection extends StatefulWidget {
  final List<CarouselItem> items;

  const HealthAdviceSection({required this.items, Key? key}) : super(key: key);

  @override
  _HealthAdviceSectionState createState() => _HealthAdviceSectionState();
}

class _HealthAdviceSectionState extends State<HealthAdviceSection> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Auto-switch banners every 6 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.items.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.20; 

    final currentItem = widget.items[_currentIndex];

    return Container(
      width: double.infinity,
      height: bannerHeight,
      decoration: BoxDecoration(
        color: orangeContainer,
        borderRadius: BorderRadius.circular(8),
        image: currentItem.image.isNotEmpty
            ? DecorationImage(
                image: AssetImage(currentItem.image), 
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3), 
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currentItem.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.035, 
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
