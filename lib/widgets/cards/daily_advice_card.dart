import 'dart:async';
import 'package:flutter/material.dart';
import 'package:armstrong/widgets/banners/patient_banner_card.dart';
import 'package:armstrong/patient/models/widgets/banner_model.dart';

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
    // Start the timer to update the banner index periodically
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // Increment index and loop back to the first banner
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
    final bannerWidth = screenWidth * 0.60;   

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02), 
      padding: EdgeInsets.all(screenWidth * 0.05), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), 
        color: const Color.fromARGB(255, 15, 100, 70),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: bannerHeight, 
        width: bannerWidth,  
        child: AnimatedSwitcher(
          duration: const Duration(seconds: 1),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: BannerCard(
            key: ValueKey<int>(_currentIndex), 
            item: widget.items[_currentIndex],
          ),
        ),
      ),
    );
  }
}
