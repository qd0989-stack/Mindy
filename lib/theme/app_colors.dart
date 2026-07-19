import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42D4);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00D9FF);
  static const Color secondaryLight = Color(0xFF5CEFFF);
  static const Color secondaryDark = Color(0xFF00A8C6);
  
  // Background Colors
  static const Color background = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFF16213E);
  static const Color backgroundCard = Color(0xFF0F3460);
  
  // Surface Colors
  static const Color surface = Color(0xFF252547);
  static const Color surfaceLight = Color(0xFF2D2D5A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color textMuted = Color(0xFF6B6B8D);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color crisis = Color(0xFFFF5252);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, backgroundLight, backgroundCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient micGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
