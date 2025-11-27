import 'package:flutter/material.dart';

/// Custom text widget for Voclio app
/// Provides consistent text styling and behavior across the app
/// Wraps Flutter's Text widget with app-specific configurations
class TextApp extends StatelessWidget {
  const TextApp({
    required this.text,
    required this.theme,
    this.maxLines,
    this.softWrap,
    this.textOverflow,
    this.textAlign,
    super.key,
  });

  /// The text content to display
  final String text;
  
  /// The text style to apply
  final TextStyle theme;
  
  /// Maximum number of lines for the text
  final int? maxLines;
  
  /// Whether the text should break at soft line breaks
  final bool? softWrap;
  
  /// How visual overflow should be handled
  final TextOverflow? textOverflow;
  
  /// How the text should be aligned horizontally
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      softWrap: softWrap,
      style: theme,
      overflow: textOverflow,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}
