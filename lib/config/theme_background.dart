import 'package:flutter/material.dart';
import 'dart:ui';

class ThemedBackground extends StatelessWidget {
  final Widget child;
  final bool applyDarkOverlay;

  const ThemedBackground({
    required this.child,
    this.applyDarkOverlay = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'images/login_bg_image.png',
            fit: BoxFit.cover,
            color: isDark && applyDarkOverlay
                ? Colors.black.withOpacity(0.5)
                : null,
            colorBlendMode:
                isDark && applyDarkOverlay ? BlendMode.darken : null,
          ),
        ),

        if (applyDarkOverlay)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.1), 
              ),
            ),
          ),

        child,
      ],
    );
  }
}
