import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? iconSize;

  CustomBackButton({
    this.onPressed,
    this.color,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_outlined,
        color: color ?? Colors.white,
        size: iconSize ?? 24.0,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
    );
  }
}
