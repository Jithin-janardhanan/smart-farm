import 'package:flutter/material.dart';

class AppColors {
  // 🌞 Light Theme
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF212121);
  static const Color lightSubText = Color(0xFF616161);
  static const Color lightPrimary = Color.fromARGB(161, 5, 66, 4);
  static const Color lightAccent = Color.fromARGB(202, 5, 135, 3);

  // 🌙 Dark Theme
  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkText = Colors.white;
  static const Color darkSubText = Colors.white70;
  static const Color darkPrimary = Color.fromARGB(224, 6, 182, 79);
  static const Color darkAccent = Color(0xFF00FF88);

  // Common Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF00E676);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightPrimary, lightPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Shadows
  static List<BoxShadow> greenGlow = [
    BoxShadow(
      color: lightAccent.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
}
