import 'package:flutter/material.dart';

/// Shared visual language aligned with the home dashboard.
abstract final class HomeSystemTokens {
  static const canvas = Color(0xFFF5F6FA);
  static const card = Colors.white;
  static const ink = Color(0xFF111827);
  static const inkMuted = Color(0xFF9CA3AF);
  static const inkSoft = Color(0xFF6B7280);
  static const purple = Color(0xFF7C5CFC);
  static const blue = Color(0xFF4A8FE7);
  static const green = Color(0xFF34C759);
  static const orange = Color(0xFFFF9500);
  static const coral = Color(0xFFFF6B6B);

  static const radiusLg = 20.0;
  static const radiusMd = 14.0;
  static const radiusSm = 10.0;

  static List<BoxShadow> cardShadow({double opacity = 0.045}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 22,
          offset: const Offset(0, 6),
        ),
      ];

  static BoxDecoration cardDecoration({Color? tint}) => BoxDecoration(
        color: tint ?? card,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: cardShadow(),
      );
}
