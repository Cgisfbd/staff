import 'package:flutter/material.dart';
import 'package:staff_app/core/theme/app_colors.dart';
import 'package:staff_app/core/theme/app_spacing.dart';

/// Enterprise Material 3 Theme strictly matching TaleemOne ERP Black & Golden Glassmorphism.
/// Complies with:
/// - 10.0px Universal Corner Radius (TaleemOne Standard)
/// - Golden Gradient & Glowing Elevated Buttons
/// - Luminous Frosted Glass Borders and Fields
class AppTheme {
  AppTheme._();

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.goldPrimary,
      foregroundColor: Colors.white,
      elevation: 3,
      shadowColor: AppColors.goldPrimary.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.3),
    ),
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: AppColors.goldLight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.goldLight,
        secondary: AppColors.goldBright,
        surface: AppColors.darkBackground,
        error: AppColors.statusAbsent,
        onPrimary: Colors.white,
        onSurface: AppColors.textDarkPrimary,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.goldLight,
        selectionColor: Color(0x40F59E0B),
        selectionHandleColor: AppColors.goldLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGlassSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.darkGlassBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.darkGlassBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.goldLight, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        hintStyle: const TextStyle(color: AppColors.textDarkMuted, fontSize: 13),
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: CardThemeData(
        color: AppColors.darkGlassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: AppColors.darkGlassBorder, width: 1.2),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide.none),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide.none),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: AppColors.goldPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.goldPrimary,
        secondary: AppColors.goldLight,
        surface: AppColors.lightBackground,
        error: AppColors.statusAbsent,
        onPrimary: Colors.white,
        onSurface: AppColors.textLightPrimary,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.goldPrimary,
        selectionColor: Color(0x33D97706),
        selectionHandleColor: AppColors.goldPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGlassSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.lightGlassBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.lightGlassBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.goldPrimary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        hintStyle: const TextStyle(color: AppColors.textLightMuted, fontSize: 13),
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightGlassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: AppColors.lightGlassBorder, width: 1.2),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide.none),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide.none),
      ),
    );
  }
}
