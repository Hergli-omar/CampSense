import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'camp_sense_colors.dart';

/// AppTheme configuration for Light and Dark modes.
/// Typography uses GoogleFonts Inter with robust local fallback.
class AppTheme {
  AppTheme._();

  static TextStyle get screenTitleStyle => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get sectionTitleStyle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyStyle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get overtitleStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  static TextStyle get monoNumberStyle => GoogleFonts.jetBrainsMono(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        surface: AppColors.lightCard,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightDanger,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: screenTitleStyle.copyWith(color: AppColors.lightTitle),
        headlineMedium: sectionTitleStyle.copyWith(color: AppColors.lightTitle),
        bodyLarge: bodyStyle.copyWith(color: AppColors.lightTextPrimary),
        bodyMedium: bodyStyle.copyWith(color: AppColors.lightTextSecondary, fontSize: 14),
        labelSmall: overtitleStyle.copyWith(color: AppColors.lightTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightDanger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightDanger, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.lightTextSecondary.withAlpha(160),
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppColors.lightPrimary,
          side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: AppColors.lightCardBorder,
      extensions: const [
        CampSenseColors(
          background: AppColors.lightBackground,
          card: AppColors.lightCard,
          cardBorder: AppColors.lightCardBorder,
          primary: AppColors.lightPrimary,
          primaryText: Colors.white,
          title: AppColors.lightTitle,
          tile: AppColors.lightTile,
          textPrimary: AppColors.lightTextPrimary,
          textSecondary: AppColors.lightTextSecondary,
          accent: AppColors.lightAccent,
          amberBackground: AppColors.lightAmberBackground,
          amberText: AppColors.lightAmberText,
          danger: AppColors.lightDanger,
          dangerTile: AppColors.lightDangerTile,
          success: AppColors.lightSuccess,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkPrimaryText,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkDanger,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: screenTitleStyle.copyWith(color: AppColors.darkTitle),
        headlineMedium: sectionTitleStyle.copyWith(color: AppColors.darkTitle),
        bodyLarge: bodyStyle.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: bodyStyle.copyWith(color: AppColors.darkTextSecondary, fontSize: 14),
        labelSmall: overtitleStyle.copyWith(color: AppColors.darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkCardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkDanger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkDanger, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.darkTextSecondary.withAlpha(160),
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkPrimaryText,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: AppColors.darkCardBorder,
      extensions: const [
        CampSenseColors(
          background: AppColors.darkBackground,
          card: AppColors.darkCard,
          cardBorder: AppColors.darkCardBorder,
          primary: AppColors.darkPrimary,
          primaryText: AppColors.darkPrimaryText,
          title: AppColors.darkTitle,
          tile: AppColors.darkTile,
          textPrimary: AppColors.darkTextPrimary,
          textSecondary: AppColors.darkTextSecondary,
          accent: AppColors.darkAccent,
          amberBackground: AppColors.darkAmberBackground,
          amberText: AppColors.darkAmberText,
          danger: AppColors.darkDanger,
          dangerTile: AppColors.darkDangerTile,
          success: AppColors.darkSuccess,
        ),
      ],
    );
  }
}
