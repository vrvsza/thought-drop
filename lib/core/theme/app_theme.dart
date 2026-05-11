import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 🌙 DARK MODE THEME - Premium Minimalist Design
// True dark theme for ThoughtDrop - calm, immersive, premium

class AppColors {
  AppColors._();

  // Primary dark backgrounds
  static const Color background = Color(0xFF050505);
  static const Color backgroundSecondary = Color(0xFF0B0B0B);
  
  // Card surfaces - subtle difference from background
  static const Color surface = Color(0xFF111111);
  static const Color surfaceVariant = Color(0xFF151515);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  
  // Accent - muted soft green
  static const Color accent = Color(0xFF6B8B6B);
  static const Color accentMuted = Color(0xFF5A745A);
  
  // Like color
  static const Color likeActive = Color(0xFFE57B7B);
  
  // Text - high contrast white
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textTertiary = Color(0xFF666666);
  
  // Utility
  static const Color error = Color(0xFFE57B7B);
  static const Color success = Color(0xFF6B9B6B);
  static const Color divider = Color(0xFF1F1F1F);
  static const Color shadow = Color(0x33000000);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentMuted,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.background,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.textTertiary,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 0.5,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w300,
        color: AppColors.textPrimary, letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w300,
        color: AppColors.textPrimary, letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500,
        color: AppColors.textTertiary, letterSpacing: 0.5,
      ),
    );
  }
}
