import 'package:flutter/material.dart';

/// App color constants for consistent theming across the application
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF1DB954);
  static const Color primaryLight = Color(0xFF1ed760);
  static const Color secondary = Color(0xFF1ed760);

  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary =
      Color(0xB3FFFFFF); // White with 70% opacity
  static const Color textHint = Color(0x80FFFFFF); // White with 50% opacity

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Gradient colors
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> backgroundGradient = [
    primary,
    primaryLight,
    background
  ];

  // Helper method to create opacity variants
  static Color withAlpha(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
