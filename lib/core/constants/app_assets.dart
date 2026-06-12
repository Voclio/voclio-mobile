import 'package:flutter/material.dart';

/// Centralized asset paths for the Voclio app.
abstract final class AppAssets {
  static const String logo = 'assets/images/logo.png';
}

/// Standard Voclio logo image used across splash, auth, dialogs, and about.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
