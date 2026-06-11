import 'package:flutter/material.dart';
import 'package:zonix/features/utils/app_colors.dart';

/// Tokens Clinical Ether para onboarding (light/dark según plataforma).
class OnboardingEtherTheme {
  OnboardingEtherTheme._(this.context);

  final BuildContext context;

  static OnboardingEtherTheme of(BuildContext context) =>
      OnboardingEtherTheme._(context);

  bool get isDark => AppColors.isPlatformDark(context);

  Color get scaffold =>
      isDark ? AppColors.etherDarkScaffold : AppColors.etherLightScaffold;

  Color get scaffoldDeep =>
      isDark ? AppColors.etherDarkScaffoldDeep : AppColors.etherLightScaffold;

  Color get textPrimary =>
      isDark ? AppColors.etherDarkText : AppColors.etherLightText;

  Color get textSecondary => textPrimary.withValues(alpha: isDark ? 0.7 : 0.6);

  Color get textMuted => textPrimary.withValues(alpha: isDark ? 0.5 : 0.6);

  Color get accent =>
      isDark ? AppColors.etherDarkAccent : AppColors.brandTeal;

  Color get ctaFill => isDark ? AppColors.brandTeal : AppColors.brandTeal;

  Color get ctaForeground =>
      isDark ? AppColors.etherDarkScaffold : AppColors.brandNavy;

  Color get fabIcon => ctaForeground;

  Color get cardSurface =>
      isDark ? AppColors.etherDarkSurface : AppColors.white;

  Color get inputFill =>
      isDark ? AppColors.etherDarkSurface : AppColors.white;

  Color get inputBorder => isDark
      ? AppColors.white.withValues(alpha: 0.05)
      : AppColors.etherLightOutline.withValues(alpha: 0.3);

  Color get inputBorderFocused => isDark
      ? AppColors.etherPrimaryFixed
      : AppColors.brandTeal;

  Color get progressTrack => isDark
      ? AppColors.etherDarkSurface
      : AppColors.white;

  Color get progressFill =>
      isDark ? AppColors.etherPrimaryFixed : AppColors.etherPrimary;

  Color get backChipBg => isDark
      ? AppColors.etherDarkSurface.withValues(alpha: 0.5)
      : AppColors.brandSurfaceLight;

  Color get backChipIcon => textPrimary;

  Color get dotInactive => AppColors.brandTeal.withValues(alpha: 0.2);

  Color get dotActive => AppColors.brandTeal;

  Color get cardBorder => isDark
      ? AppColors.white.withValues(alpha: 0.05)
      : AppColors.etherLightOutline.withValues(alpha: 0.2);

  Color get sectionHeader =>
      isDark ? AppColors.etherDarkText.withValues(alpha: 0.85) : AppColors.etherLightTextSecondary;

  Color get pinColor => AppColors.brandTeal;

  Color get bannerBg =>
      AppColors.brandTeal.withValues(alpha: 0.1);

  Color get bannerBorder =>
      AppColors.brandTeal.withValues(alpha: 0.2);

  LinearGradient get scaffoldGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.etherDarkScaffold,
            AppColors.etherDarkScaffoldDeep,
          ],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.etherLightScaffold,
            AppColors.etherLightScaffold,
          ],
        );

  BoxDecoration scaffoldDecoration({Alignment radialCenter = Alignment.topCenter}) {
    if (isDark) {
      return BoxDecoration(
        color: AppColors.etherDarkScaffold,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.etherPrimary.withValues(alpha: 0.15),
            AppColors.etherDarkScaffold,
          ],
        ),
      );
    }
    return BoxDecoration(
      color: AppColors.etherLightScaffold,
      gradient: RadialGradient(
        center: radialCenter,
        radius: 1.0,
        colors: [
          AppColors.brandTeal.withValues(alpha: 0.08),
          AppColors.etherLightScaffold,
        ],
        stops: const [0.0, 0.65],
      ),
    );
  }
}
