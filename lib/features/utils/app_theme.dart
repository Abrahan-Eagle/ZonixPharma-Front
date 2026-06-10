import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zonix/features/utils/app_colors.dart';

/// Tema visual Zonix Pharma (light + dark) basado en `AppColors.brand*`.
/// Tipografía: Plus Jakarta Sans (vía Google Fonts).
const Color stitchPrimary = AppColors.brandTeal;
const Color stitchOnPrimary = AppColors.white;
const Color stitchSecondary = AppColors.brandNavy;
const Color stitchBgLight = AppColors.brandSurfaceLight;
const Color stitchBgDark = AppColors.brandSurfaceDark;
const Color stitchSurfaceDark = AppColors.brandSurfaceContainerDark;
const Color stitchCardCream = AppColors.stitchCardCream;
const Color stitchNavBg = AppColors.brandNavy;
const Color stitchNavActive = AppColors.brandTeal;
const Color stitchSlate400 = AppColors.stitchSlate400;

ThemeData buildStitchLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    primaryColor: AppColors.brandNavy,
    scaffoldBackgroundColor: stitchBgLight,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.brandNavy,
      foregroundColor: stitchOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: stitchOnPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: stitchOnPrimary),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.brandNavy,
      onPrimary: AppColors.white,
      secondary: AppColors.brandTeal,
      onSecondary: AppColors.white,
      tertiary: AppColors.brandCtaAccent,
      onTertiary: AppColors.white,
      error: AppColors.statusError,
      onError: AppColors.white,
      surface: stitchBgLight,
      onSurface: AppColors.stitchTextDark,
    ),
    cardColor: AppColors.white,
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandTeal,
        foregroundColor: AppColors.brandNavy,
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandNavy,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.brandNavy, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandTealDeep,
        minimumSize: const Size(0, 48),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brandTeal,
      foregroundColor: AppColors.brandNavy,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brandStrokeLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brandTeal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.brandTeal,
      unselectedItemColor: AppColors.stitchSlate400,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.brandStrokeLight,
      thickness: 1,
    ),
  );
}

ThemeData buildStitchDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    primaryColor: AppColors.brandTeal,
    scaffoldBackgroundColor: stitchBgDark,
    appBarTheme: AppBarTheme(
      backgroundColor: stitchBgDark,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      iconTheme: const IconThemeData(color: AppColors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brandTeal,
      onPrimary: AppColors.brandSurfaceDark,
      secondary: AppColors.brandMint,
      onSecondary: AppColors.brandSurfaceDark,
      tertiary: AppColors.brandCtaAccent,
      onTertiary: AppColors.brandSurfaceDark,
      error: AppColors.statusError,
      onError: AppColors.white,
      surface: AppColors.brandSurfaceContainerDark,
      onSurface: AppColors.white,
    ),
    cardColor: AppColors.brandSurfaceContainerDark,
    cardTheme: CardThemeData(
      color: AppColors.brandSurfaceContainerDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandTeal,
        foregroundColor: AppColors.brandSurfaceDark,
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandMint,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.brandMint, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandMint,
        minimumSize: const Size(0, 48),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brandTeal,
      foregroundColor: AppColors.brandSurfaceDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.brandSurfaceContainerDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brandStrokeDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.brandTeal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.brandNavy,
      selectedItemColor: AppColors.brandTeal,
      unselectedItemColor: AppColors.stitchSlate400,
      type: BottomNavigationBarType.fixed,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.brandStrokeDark,
      thickness: 1,
    ),
  );
}
