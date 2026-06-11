import 'package:zonix/features/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'onboarding_ether_theme.dart';
import 'onboarding_provider.dart';
import 'client_onboarding_flow.dart';
import 'commerce_onboarding_flow.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({super.key});

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    final ether = OnboardingEtherTheme.of(context);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = w < 360;
    final isTablet = w > 600;

    return Stack(
      children: [
        _buildBackground(ether),
        SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: h -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 20 : (isTablet ? 32 : 24),
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context, ether, isSmall),
                    const SizedBox(height: 32),
                    _buildRoleCard(
                      ether: ether,
                      role: 'users',
                      title: 'Soy Cliente',
                      subtitle: 'Quiero comprar mis medicamentos',
                      icon: Icons.shopping_bag_outlined,
                      iconColor: AppColors.brandTeal,
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      ether: ether,
                      role: 'commerce',
                      title: 'Tengo una Farmacia',
                      subtitle: 'Quiero vender mis productos',
                      icon: Icons.storefront_outlined,
                      iconColor: AppColors.brandMint,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'ZONIX PHARMA UNIVERSE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ether.textMuted.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildContinueButton(context, ether, w),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              '¿Cómo elegir?',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Elige Soy Cliente si quieres comprar medicamentos. '
                              'Elige Tengo una Farmacia si administras un comercio '
                              'y quieres vender en Zonix Pharma.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        '¿Necesitas ayuda para decidir?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: ether.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(OnboardingEtherTheme ether) {
    if (!ether.isDark) {
      return Container(color: ether.scaffold);
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.etherDarkScaffold,
            AppColors.etherDarkScaffoldDeep,
          ],
        ),
      ),
      child: Stack(
        children: [
          ..._buildStars(),
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandTeal.withValues(alpha: 0.2),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandMint.withValues(alpha: 0.1),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final positions = [
      Offset(0.1 * w, 0.15 * h),
      Offset(0.2 * w, 0.35 * h),
      Offset(0.25 * w, 0.8 * h),
      Offset(0.45 * w, 0.2 * h),
      Offset(0.65 * w, 0.4 * h),
    ];
    return positions.map((p) {
      return Positioned(
        left: p.dx,
        top: p.dy,
        child: Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildHeader(
    BuildContext context,
    OnboardingEtherTheme ether,
    bool isSmall,
  ) {
    final titleSize = isSmall ? 24.0 : 28.0;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ether.isDark
                ? AppColors.etherDarkSurface.withValues(alpha: 0.7)
                : AppColors.brandSurfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ether.isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.etherLightOutline.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            Icons.rocket_launch,
            color: ether.isDark ? ether.accent : AppColors.etherPrimary,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Cómo quieres\nexplorar hoy?',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            height: 1.2,
            color: ether.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Elige tu misión.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isSmall ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: ether.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required OnboardingEtherTheme ether,
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() => selectedRole = role);
        Provider.of<OnboardingProvider>(context, listen: false).setRole(role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ether.isDark
              ? AppColors.etherDarkSurface
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.brandTeal
                : (ether.isDark
                    ? AppColors.transparent
                    : AppColors.etherLightOutline.withValues(alpha: 0.15)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandTeal.withValues(
                      alpha: ether.isDark ? 0.15 : 0.08,
                    ),
                    blurRadius: ether.isDark ? 30 : 12,
                    spreadRadius: 0,
                  ),
                ]
              : (ether.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFF005048).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor.withValues(alpha: 0.2),
                    iconColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ether.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: ether.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.brandTeal : AppColors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.brandTeal
                      : ether.textMuted.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: ether.isDark
                          ? AppColors.etherDarkScaffold
                          : AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    OnboardingEtherTheme ether,
    double w,
  ) {
    final enabled = selectedRole != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled
            ? () async {
                if (selectedRole == null) return;
                final onboardingProvider =
                    Provider.of<OnboardingProvider>(context, listen: false);

                if (selectedRole == 'users') {
                  onboardingProvider.setRole('users');
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientOnboardingFlow(),
                    ),
                  );
                } else if (selectedRole == 'commerce') {
                  onboardingProvider.setRole('commerce');
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommerceOnboardingFlow(),
                    ),
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.brandTeal
              : AppColors.brandTeal.withValues(alpha: 0.4),
          foregroundColor: ether.ctaForeground,
          disabledBackgroundColor: AppColors.brandTeal.withValues(alpha: 0.3),
          disabledForegroundColor: ether.ctaForeground.withValues(alpha: 0.5),
          elevation: enabled ? (ether.isDark ? 4 : 2) : 0,
          shadowColor: AppColors.brandTeal.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continuar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
