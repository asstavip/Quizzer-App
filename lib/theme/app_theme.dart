// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final customColors = {
    'primary': const Color(0xFF6C63FF),
    'secondary': const Color(0xFF2A2D3E),
    'background': const Color(0xFFF5F7FF),
    'surface': Colors.white,
    'error': const Color(0xFFFF6B6B),
    'success': const Color(0xFF4CAF50),
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: customColors['primary']!,
        secondary: customColors['secondary']!,
        surface: customColors['surface']!,
        error: customColors['error']!,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: customColors['primary'],
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColors['primary'],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: customColors['primary'],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: customColors['surface'],
      ),
      scaffoldBackgroundColor: customColors['background'],
    );
  }
}
