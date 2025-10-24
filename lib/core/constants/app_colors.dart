import 'package:flutter/material.dart';

/// Allnimall Color Palette
/// Primary: Dark Blue-Purple (#3A3D71)
/// Secondary: Bright Pink (#EF487F)
/// Accent/Neutral: Putih, abu-abu muda
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF3A3D71); // Dark Blue-Purple
  static const Color primaryLight = Color(0xFF5B5E99);
  static const Color primaryDark = Color(0xFF252751);

  // Secondary Colors
  static const Color secondary = Color(0xFFEF487F); // Bright Pink
  static const Color secondaryLight = Color(0xFFF573A0);
  static const Color secondaryDark = Color(0xFFD12E61);

  // Tertiary Colors (Playful Blue)
  static const Color tertiary = Color(0xFF5B9FFF); // Bright playful blue
  static const Color tertiaryLight = Color(0xFF8BB8FF);
  static const Color tertiaryDark = Color(0xFF3D7AD9);

  // Quaternary Colors (Playful Green)
  static const Color quaternary = Color(0xFF5FD4A0); // Playful green
  static const Color quaternaryLight = Color(0xFF8BE4BE);
  static const Color quaternaryDark = Color(0xFF3FAF7E);

  // Accent Colors
  static const Color accent = Color(0xFFFFD700); // Gold
  static const Color accentTurquoise = Color(0xFF40E0D0); // Turquoise

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF616161);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Lost Pet Alert
  static const Color lostPetBanner = Color(0xFFFF3B30);
  static const Color lostPetBackground = Color(0xFFFFF3F2);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryLight];

  static const List<Color> secondaryGradient = [secondary, secondaryLight];

  static const List<Color> heroGradient = [primary, secondary];
}
