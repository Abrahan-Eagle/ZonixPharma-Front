import 'package:zonix/features/utils/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_ether_theme.dart';

class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _spinController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ether = OnboardingEtherTheme.of(context);

    return Stack(
      children: [
        _buildBackground(context, ether),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: _buildIllustration(context, ether),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = MediaQuery.of(context).size.width;
                  final isSmall = w < 360;
                  final isTablet = w > 600;
                  final titleSize = isSmall ? 24.0 : (w < 400 ? 26.0 : 28.0);
                  final bodySize = isSmall ? 14.0 : 16.0;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 24 : (isTablet ? 40 : 32),
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Pide en un',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: ether.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'par de clics',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.bold,
                                    color: ether.accent,
                                    height: 1.25,
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  height: 8,
                                  child: CustomPaint(
                                    painter: _CurvedUnderlinePainter(
                                      color: AppColors.brandTeal
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Elige tus medicamentos, confirma tu ubicación y recíbelos en tu puerta.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: bodySize,
                            fontWeight: FontWeight.w400,
                            color: ether.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(BuildContext context, OnboardingEtherTheme ether) {
    final size = MediaQuery.of(context).size;
    if (!ether.isDark) {
      return Container(
        decoration: ether.scaffoldDecoration(
          radialCenter: Alignment.topCenter,
        ),
      );
    }
    return Container(
      color: AppColors.etherDarkScaffold,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: size.width * 0.5 - size.width * 0.6,
            child: Container(
              width: size.width * 1.2,
              height: size.height * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.etherPrimary.withValues(alpha: 0.2),
                    AppColors.transparent,
                  ],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),
          Positioned(
            right: -size.width * 0.4,
            bottom: -size.height * 0.2,
            child: Container(
              width: size.width,
              height: size.height * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandTeal.withValues(alpha: 0.1),
                    AppColors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context, OnboardingEtherTheme ether) {
    final size = MediaQuery.of(context).size;
    final isDark = ether.isDark;
    final isSmallScreen = size.width < 360 || size.height < 600;
    final scale = isSmallScreen ? 0.8 : (size.width / 400).clamp(0.9, 1.05);
    final glowSize = 256.0 * scale;
    final ringSize = 288.0 * scale;
    final dashedSize = 352.0 * scale;
    final centerSize = 128.0 * scale;
    final orbSizes = [64.0 * scale, 56.0 * scale, 48.0 * scale];
    const orbIcons = [
      Icons.medication,
      Icons.local_pharmacy,
      Icons.vaccines,
    ];

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (isDark)
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) {
              final pulse =
                  0.5 + 0.15 * math.sin(_floatController.value * math.pi);
              return Container(
                width: glowSize,
                height: glowSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandTeal.withValues(alpha: 0.15 * pulse),
                      AppColors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              );
            },
          ),
        Container(
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.brandTeal.withValues(alpha: 0.1),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _spinController,
          builder: (context, _) {
            return Transform.rotate(
              angle: _spinController.value * 2 * math.pi,
              child: SizedBox(
                width: dashedSize,
                height: dashedSize,
                child: CustomPaint(
                  painter: _DashedCirclePainter(
                    color: AppColors.brandTeal.withValues(alpha: 0.2),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(
          width: 256 * scale,
          height: 256 * scale,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: centerSize,
                height: centerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.etherPrimary,
                            AppColors.etherSecondaryDeep,
                          ]
                        : [
                            AppColors.brandTeal,
                            AppColors.etherPrimaryFixed,
                          ],
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: AppColors.brandTeal.withValues(alpha: 0.4),
                            blurRadius: 30,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.brandTeal.withValues(alpha: 0.25),
                            blurRadius: 20,
                          ),
                        ],
                ),
                child: Icon(
                  Icons.local_pharmacy,
                  size: centerSize * 0.5,
                  color: isDark
                      ? AppColors.etherPrimaryFixed
                      : AppColors.etherOnPrimaryFixed,
                ),
              ),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final float = 10 * math.sin(_floatController.value * math.pi);
                  return Positioned(
                    top: -16 * scale + float,
                    right: 16 * scale,
                    child: Transform.rotate(
                      angle: 12 * math.pi / 180,
                      child: _buildPharmaOrb(ether, orbIcons[0], orbSizes[0]),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final float =
                      8 * math.sin(_floatController.value * math.pi + 1);
                  return Positioned(
                    bottom: float,
                    left: -8 * scale,
                    child: Transform.rotate(
                      angle: -12 * math.pi / 180,
                      child: _buildPharmaOrb(ether, orbIcons[1], orbSizes[1]),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final float =
                      6 * math.sin(_floatController.value * math.pi + 2);
                  return Positioned(
                    bottom: 32 * scale - float,
                    right: -24 * scale,
                    child: Transform.rotate(
                      angle: 6 * math.pi / 180,
                      child: _buildPharmaOrb(ether, orbIcons[2], orbSizes[2]),
                    ),
                  );
                },
              ),
              if (isDark) ...[
                Positioned(
                  top: 0,
                  left: 40 * scale,
                  child: _particle(8 * scale, 0.6),
                ),
                Positioned(
                  bottom: 40 * scale,
                  right: 80 * scale,
                  child: _particle(6 * scale, 0.4),
                ),
                Positioned(
                  top: 120 * scale,
                  right: -32 * scale,
                  child: _particle(4 * scale, 0.8),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPharmaOrb(
    OnboardingEtherTheme ether,
    IconData icon,
    double size,
  ) {
    final isDark = ether.isDark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.etherDarkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: AppColors.brandTeal.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.45,
        color: isDark ? ether.accent : AppColors.etherPrimary,
      ),
    );
  }

  Widget _particle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.etherDarkAccent.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandTeal.withValues(alpha: opacity * 0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashLength = 8.0;
    const gapLength = 6.0;
    final radius = size.width / 2 - 0.5;
    final center = Offset(size.width / 2, size.height / 2);
    var angle = 0.0;
    while (angle < 2 * math.pi) {
      final startAngle = angle;
      angle += dashLength / radius;
      final sweepAngle =
          (dashLength / radius).clamp(0.0, 2 * math.pi - startAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      angle += gapLength / radius;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurvedUnderlinePainter extends CustomPainter {
  final Color color;

  _CurvedUnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height,
        size.width,
        size.height * 0.5,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
