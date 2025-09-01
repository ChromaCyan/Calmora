import 'package:flutter/material.dart';

class SegmentedProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int segments;
  final Color filledColor;
  final Color emptyColor;
  final double height;
  final double spacing;

  const SegmentedProgressBar({
    Key? key,
    required this.progress,
    required this.segments,
    required this.filledColor,
    required this.emptyColor,
    this.height = 8,
    this.spacing = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate how many segments should be filled
    int filledSegments = (progress * segments).ceil();

    // Ensure at least 1 is filled (first question)
    if (filledSegments == 0 && segments > 0) {
      filledSegments = 1;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(segments, (index) {
        bool isFilled = index < filledSegments;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: height,
              decoration: BoxDecoration(
                color: isFilled ? filledColor : emptyColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }
}
