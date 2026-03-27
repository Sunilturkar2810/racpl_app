import 'package:flutter/material.dart';

class AppColors {
  // Primary & Secondary
  static const Color primary = Color(0xFF003366);
  static const Color secondary = Color(0xFFF5F7FA);
  static const Color accent = Color(0xFFFF6B00);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5F7FA); // Light mode background
  static const Color surface = Colors.white; // Light mode surface (cards, etc.)
  
  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFFCC00);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF5856D6);

  // Neutral / Greyscale
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color border = Color(0xFFC7C7CC);
  static const Color divider = Color(0xFFE5E5EA);

  // Dark Mode specific
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
}
