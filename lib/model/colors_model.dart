import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8F9FA);
  static const Color primaryColor = Color(0xFF2E7D32); // Used in ThemeData
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color white = Colors.white;
  static const Color black = Colors.black; //
  static const Color textGrey = Color(0xFF424242);

  static Color primaryGreenOpacity(double opacity) =>
      primaryGreen.withOpacity(opacity);

  static Color secondaryGreenOpacity(double opacity) =>
      secondaryGreen.withOpacity(opacity);
}
