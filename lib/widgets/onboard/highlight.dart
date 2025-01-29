import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class Highlight extends StatelessWidget {
  const Highlight({
    Key? key,
    required this.globalKey,
    required this.title,
    required this.description,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: globalKey,
      title: title,
      description: description,
      child: child,
      onTargetClick: onTap,
    );
  }
}