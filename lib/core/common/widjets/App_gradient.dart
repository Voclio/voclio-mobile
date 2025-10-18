import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.padding,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        colors.accent!.withOpacity(0.15),
        colors.primary!.withOpacity(0.08),
        colors.background!,
      ],
    );

    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(gradient: gradient),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
//سس
    if (useSafeArea) content = SafeArea(child: content);

    return content;
  }
}
