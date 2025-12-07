import 'package:flutter/material.dart';

enum TaskPriority {
  high,
  medium,
  low,
  none;

  // Helper to get color based on design
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return const Color(0xFFFF8A80); // Red/Pinkish
      case TaskPriority.medium:
        return const Color(0xFFFFD180); // Orange
      case TaskPriority.low:
        return const Color(0xFF80D8FF); // Blue
      case TaskPriority.none:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String get displayName => name[0].toUpperCase() + name.substring(1);
}

enum AppTag {
  all, // Added 'All' for the filter tabs in UI
  study,
  work,
  ideas,
  health,
  personal,
  planning,
  meeting,
  reading;

  // Helper for UI Chips
  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }

  // Assign colors based on your design palette
  Color get color {
    switch (this) {
      case AppTag.work:
        return const Color(0xFFE0F7FA); // Cyan tint
      case AppTag.personal:
        return const Color(0xFFF3E5F5); // Purple tint
      case AppTag.health:
        return const Color(0xFFE8F5E9); // Green tint
      case AppTag.study:
        return const Color(0xFFFFF3E0); // Orange tint
      default:
        return const Color(0xFFECEFF1); // Grey
    }
  }
}
