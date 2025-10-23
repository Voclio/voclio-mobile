import 'package:flutter/material.dart';
import 'package:voclio_app/core/extentions/context_extentions.dart';

class LinearContainer extends StatelessWidget {
  const LinearContainer({
    super.key,
    required this.child
  });
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.accentDark!.withOpacity(0.15),
            context.colors.primary!.withOpacity(0.08),
            context.colors.background!,
          ],
        ),
      ),
      child: child
    );
  }
}

