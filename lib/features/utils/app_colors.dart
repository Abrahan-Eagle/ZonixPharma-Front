import 'package:flutter/material.dart';

/// Sistema de color Zonix Pharma.
///
/// Los nombres `brand*` son los tokens canónicos de la marca Pharma.
/// Se conservan **alias** con los nombres antiguos del proyecto Eats
/// (`blue`, `blueDark`, `yellow`, `orange`, `orangeCoral`, `red`, `green`,
/// `cream`, `purple`, `teal`, etc.) mapeados a tokens Pharma para no
/// romper las pantallas existentes en este sprint. Los alias se
/// eliminarán en un PR de cierre cuando todas las vistas consuman tokens
/// `brand*` o `Theme.colorScheme`.
///
/// Paleta canónica (BRAND_ZONIX_PHARMA.md):
///   Primary navy        #1E2A5A   confianza farmacéutica, navegación
///   Deep teal           #0F4C5C   superficies oscuras / acento secundario
///   Teal accent         #56C7B8   CTA principal, marca, energía
///   Light mint          #A8DCCB   highlights, badges, fondo decorativo
///   Surface light       #F5F7FA   canvas claro
///   Muted gray          #C7CFD9   bordes, dividers, texto secundario
///   Surface dark        #142033   canvas oscuro
///   CTA accent (warm)   #F2A65A   CTAs primarios muy puntuales / microaccesos
class AppColors {
  // ─────────────────────────────────────────────────────────
  // Tokens canónicos Pharma
  // ─────────────────────────────────────────────────────────
  static const Color brandNavy = Color(0xFF1E2A5A);
  static const Color brandTealDeep = Color(0xFF0F4C5C);
  static const Color brandTeal = Color(0xFF56C7B8);
  static const Color brandMint = Color(0xFFA8DCCB);
  static const Color brandSurfaceLight = Color(0xFFF5F7FA);
  static const Color brandMutedGray = Color(0xFFC7CFD9);
  static const Color brandSurfaceDark = Color(0xFF142033);
  static const Color brandCtaAccent = Color(0xFFF2A65A);

  // Acentos derivados (sombras y estados)
  static const Color brandNavyDeep = Color(0xFF142033);
  static const Color brandTealSoft = Color(0xFF7BD9CC);
  static const Color brandTealOnDark = Color(0xFF6FD7C9);
  static const Color brandSurfaceDarkLighter = Color(0xFF1F2E45);
  static const Color brandSurfaceContainerDark = Color(0xFF16202A);
  static const Color brandStrokeLight = Color(0xFFE2E8F0);
  static const Color brandStrokeDark = Color(0xFF334155);

  // ─────────────────────────────────────────────────────────
  // Estados semánticos (no del logo, pero parte del sistema)
  // ─────────────────────────────────────────────────────────
  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color statusSuccess = Color(0xFF22C55E);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);

  // ─────────────────────────────────────────────────────────
  // Aliases legacy (no usar en código nuevo - se eliminan al final)
  // Mantenidos para evitar churn en 70+ archivos durante el sprint.
  // ─────────────────────────────────────────────────────────
  static const Color blueDark = brandNavy;
  static const Color blue = brandTeal;
  static const Color blueLight = brandMint;
  static const Color yellow = brandCtaAccent;
  static const Color orange = brandCtaAccent;
  static const Color orangeCoral = brandCtaAccent;
  static const Color red = statusError;
  static const Color green = statusSuccess;
  static const Color teal = brandTeal;
  static const Color amber = statusWarning;
  static const Color purple = brandTealDeep;
  static const Color brown = brandTealDeep;

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white60 = Colors.white60;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white24 = Colors.white24;
  static const Color white12 = Colors.white12;
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color black45 = Colors.black45;
  static const Color black38 = Colors.black38;
  static const Color black26 = Colors.black26;
  static const Color black12 = Colors.black12;
  static const Color transparent = Colors.transparent;

  static const Color surfaceDarkLighter = brandSurfaceDarkLighter;
  static const Color scaffoldBgLight = brandSurfaceLight;
  static const Color grayLight = brandSurfaceLight;
  static const Color backgroundDark = brandSurfaceDark;

  // ─────────────────────────────────────────────────────────
  // Tokens "Stitch" Pharma (templates de pantallas existentes).
  // Reasignados a paleta Pharma; nombres conservados para
  // no romper las plantillas de buyer (confirmación, chat, etc).
  // ─────────────────────────────────────────────────────────
  static const Color stitchTextDark = Color(0xFF0F172A);
  static const Color stitchSlate = Color(0xFF64748B);
  static const Color stitchSlate400 = Color(0xFF94A3B8);
  static const Color stitchBgCard = Color(0xFFF1F5F9);
  static const Color stitchAmber = brandCtaAccent;
  static const Color stitchCardCream = Color(0xFFEDF6F4);
  static const Color stitchNavBg = brandNavy;
  static const Color stitchSurfaceLighter = brandSurfaceDarkLighter;
  static const Color stitchPink400 = brandCtaAccent;
  static const Color whatsappGreen = Color(0xFF25D366);

  // Off-white / acentos suaves
  static const Color cream = brandSurfaceLight;
  static const Color inputBg = Color(0xFFF8F9FA);
  static const Color borderLight = brandStrokeLight;
  static const Color textSecondaryDark = Color(0xFF2C3E50);
  static const Color onboardingCompanyBlue = brandTealDeep;
  static const Color onboardingDeliveryPurple = brandTeal;
  static const Color surfaceHighlight = Color(0xFF233040);
  static const Color onboardingPurpleAccent = brandMint;
  static const Color backgroundDarker = Color(0xFF0D1218);
  static const Color cardDarkSlate = Color(0xFF1E293B);
  static const Color ratingAmberLight = Color(0xFFFBBF24);
  static const Color ratingAmberDark = Color(0xFFD97706);

  // Onboarding
  static const Color addressPrimary = brandCtaAccent;
  static const Color onboardingBlueDark = brandNavy;
  static const Color onboardingGradientStart = brandNavy;
  static const Color onboardingBlueLight = brandTeal;
  static const Color blueDeep = brandNavy;
  static const Color blueMedium = brandTeal;
  static const Color blueDarkMid = Color(0xFF23456B);
  static const Color blueLight50 = Color(0xFFEFF6FF);
  static const Color blueLight400 = brandTealSoft;
  static const Color greenLight100 = Color(0xFFDCFCE7);
  static const Color slateLight50 = Color(0xFFF8FAFC);

  /// Gradientes del banner "salud del sistema" en admin dashboard.
  static const Color adminHealthPositiveStartDark = Color(0xFF0D4A2E);
  static const Color adminHealthPositiveEndDark = Color(0xFF064E3B);
  static const Color adminHealthNegativeStartDark = Color(0xFF4A0D0D);
  static const Color adminHealthNegativeEndDark = Color(0xFF7F1D1D);
  static const Color adminHealthPositiveEndLight = Color(0xFFA7F3D0);
  static const Color adminHealthNegativeStartLight = Color(0xFFFEE2E2);
  static const Color adminHealthNegativeEndLight = Color(0xFFFCA5A5);

  // ─────────────────────────────────────────────────────────
  // Helpers light/dark
  // ─────────────────────────────────────────────────────────
  static Color scaffoldBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? brandSurfaceDark
          : brandSurfaceLight;

  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? brandSurfaceContainerDark
          : white;

  static Color headerGradientStart(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? brandSurfaceDark
          : brandNavy;

  static Color headerGradientMid(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? brandTealDeep
          : brandTeal;

  static Color headerGradientEnd(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? brandTeal
          : brandTealSoft;

  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? white : brandNavy;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? white70 : brandTealDeep;

  static Color primaryButton(BuildContext context) => brandTeal;
  static Color accentButton(BuildContext context) => brandNavy;
  static Color error(BuildContext context) => statusError;
  static Color success(BuildContext context) => statusSuccess;

  /// Tokens Stitch (plantilla confirmación pedido) - canvas y sección.
  static const Color stitchCanvasDark = brandSurfaceDark;
  static const Color stitchSurfaceContainer = brandSurfaceContainerDark;

  /// Extremo del degradado en CTA primarios (mapping Pharma del antiguo "inverse-primary").
  static const Color stitchInversePrimary = brandTealDeep;

  /// AppBar fija de chat (mismo tono que canvas dark).
  static const Color stitchChatAppBar = brandSurfaceDark;
}
