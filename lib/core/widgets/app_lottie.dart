import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottie extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const AppLottie({
    super.key,
    required this.assetName,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final path = assetName.startsWith('assets/')
        ? assetName
        : 'assets/lotties/$assetName${assetName.endsWith('.json') ? '' : '.json'}';
    return Lottie.asset(path, width: width, height: height, fit: fit);
  }
}
