import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GlobalLoader {
  static Widget loader = Center(
    child: Lottie.asset(
      'images/loading2.json',
      width: 150,
      height: 150,
    ),
  );
}
