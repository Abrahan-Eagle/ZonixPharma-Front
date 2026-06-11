import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zonix/app/main_router.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'onboarding_ether_theme.dart';

/// Pantalla de éxito post-onboarding (template 09_success_screen_dual_mode).
class OnboardingSuccessScreen extends StatefulWidget {
  const OnboardingSuccessScreen({
    super.key,
    required this.isCommerce,
  });

  final bool isCommerce;

  @override
  State<OnboardingSuccessScreen> createState() =>
      _OnboardingSuccessScreenState();
}

class _OnboardingSuccessScreenState extends State<OnboardingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _roleLabel =>
      widget.isCommerce ? 'Farmacia Partner' : 'Cliente Zonix';

  void _onBegin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainRouter()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ether = OnboardingEtherTheme.of(context);
    final isDark = ether.isDark;

    return Scaffold(
      backgroundColor: ether.scaffold,
      body: Stack(
        children: [
          if (isDark)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.5 - 150,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandTeal.withValues(alpha: 0.15),
                      AppColors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeroCheck(ether),
                        const SizedBox(height: 32),
                        Text(
                          '¡Todo listo!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: ether.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tu perfil ha sido configurado con éxito. Ya puedes empezar a disfrutar de Zonix Pharma.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: ether.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildRoleBadge(ether),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onBegin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandTeal,
                        foregroundColor: isDark
                            ? AppColors.etherDarkScaffold
                            : AppColors.white,
                        elevation: isDark ? 4 : 1,
                        shadowColor: AppColors.brandTeal.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Comenzar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCheck(OnboardingEtherTheme ether) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.08);
        return SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale * 1.5,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandTeal.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Transform.scale(
                scale: scale * 1.1,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandTeal.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ether.isDark
                      ? AppColors.etherDarkSurface.withValues(alpha: 0.2)
                      : AppColors.white,
                  border: ether.isDark
                      ? Border(
                          top: BorderSide(
                            color: AppColors.white.withValues(alpha: 0.1),
                          ),
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandTeal.withValues(
                        alpha: ether.isDark ? 0.3 : 0.2,
                      ),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: ether.isDark ? ether.accent : AppColors.brandTeal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(OnboardingEtherTheme ether) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: ether.isDark
            ? AppColors.etherDarkSurface.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ether.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandTeal.withValues(alpha: 0.1),
            ),
            child: Icon(
              widget.isCommerce ? Icons.local_pharmacy : Icons.person,
              color: ether.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perfil configurado',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: ether.textMuted,
                ),
              ),
              Text(
                _roleLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ether.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
