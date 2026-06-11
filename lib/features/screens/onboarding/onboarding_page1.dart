import 'package:zonix/features/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_ether_theme.dart';

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final ether = OnboardingEtherTheme.of(context);
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;
    final isTablet = w > 600;
    final padH = isSmall ? 16.0 : (isTablet ? 32.0 : 24.0);
    return Stack(
      children: [
        _buildBackground(context, ether),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padH, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, ether),
                const SizedBox(height: 32),
                _buildBenefitCards(context, ether),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(BuildContext context, OnboardingEtherTheme ether) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: ether.isDark
          ? const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.2,
                colors: [
                  Color(0xFF0E2242),
                  AppColors.etherDarkScaffold,
                ],
                stops: [0.0, 0.6],
              ),
            )
          : BoxDecoration(color: ether.scaffold),
      child: ether.isDark
          ? Stack(
              children: [
                Positioned(
                    top: size.height * 0.1,
                    left: size.width * 0.2,
                    child: _starDot(0.4, 2)),
                Positioned(
                    top: size.height * 0.3,
                    right: size.width * 0.15,
                    child: _starDot(0.6, 3)),
                Positioned(
                    bottom: size.height * 0.2,
                    left: size.width * 0.1,
                    child: _starDot(0.8, 1)),
              ],
            )
          : null,
    );
  }

  Widget _starDot(double opacity, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OnboardingEtherTheme ether) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;
    final iconSize = isSmall ? 56.0 : 64.0;
    final titleSize = isSmall ? 24.0 : (w < 400 ? 26.0 : 28.0);
    const bodySize = 14.0;
    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.brandTeal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.brandTeal.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.health_and_safety,
            size: iconSize * 0.56,
            color: ether.isDark ? ether.accent : AppColors.brandTeal,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '¿Por qué elegir Zonix?',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: ether.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tu farmacia de confianza: medicamentos y cuidado de salud, con la claridad que mereces.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: bodySize,
            fontWeight: FontWeight.w500,
            color: ether.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitCards(BuildContext context, OnboardingEtherTheme ether) {
    return Column(
      children: [
        _buildBenefitCard(
          context,
          ether,
          icon: Icons.local_shipping_outlined,
          title: 'Entrega confiable',
          description:
              'Recibe tus medicamentos en casa con seguimiento en tiempo real.',
        ),
        const SizedBox(height: 16),
        _buildBenefitCard(
          context,
          ether,
          icon: Icons.local_pharmacy,
          title: 'Farmacias verificadas',
          description:
              'Catálogo claro y farmacias de confianza para pedir con tranquilidad.',
        ),
        const SizedBox(height: 16),
        _buildBenefitCard(
          context,
          ether,
          icon: Icons.medication_liquid,
          title: 'Recetas y OTC',
          description:
              'Gestiona medicamentos con y sin receta desde un solo lugar.',
        ),
      ],
    );
  }

  Widget _buildBenefitCard(
    BuildContext context,
    OnboardingEtherTheme ether, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;
    const pad = 16.0;
    final titleSize = isSmall ? 16.0 : 18.0;
    const bodySize = 14.0;
    final iconColor = ether.isDark ? ether.accent : AppColors.etherPrimary;

    return Container(
      padding: const EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: ether.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ether.cardBorder),
        boxShadow: ether.isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF005048).withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: ether.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: bodySize,
                    fontWeight: FontWeight.w400,
                    color: ether.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
