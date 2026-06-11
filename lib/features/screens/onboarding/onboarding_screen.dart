import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_ether_theme.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';

import 'package:zonix/features/utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final bool _isLoading = false;

  List<Widget> get onboardingPages {
    return [
      const WelcomePage(),
      const OnboardingPage1(),
      const OnboardingPage2(),
      const OnboardingPage3(),
    ];
  }

  void _handleNext() {
    if (_isLoading) return;

    if (_currentPage == onboardingPages.length - 1) {
      return;
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _handleBack() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ether = OnboardingEtherTheme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ether.scaffold,
        body: Stack(
          children: [
            PageView(
              controller: _controller,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: onboardingPages,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: onboardingPages.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          activeDotColor: ether.dotActive,
                          dotColor: ether.dotInactive,
                          spacing: 8,
                          expansionFactor: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentPage > 0)
                            TextButton(
                              onPressed: _handleBack,
                              child: Text(
                                'Atrás',
                                style: TextStyle(color: ether.textPrimary),
                              ),
                            )
                          else
                            const SizedBox(width: 80),
                          if (_currentPage < onboardingPages.length - 1)
                            FloatingActionButton(
                              heroTag: 'onboarding_next',
                              onPressed: _handleNext,
                              backgroundColor: ether.ctaFill,
                              foregroundColor: ether.fabIcon,
                              elevation: ether.isDark ? 4 : 2,
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: ether.fabIcon,
                                      strokeWidth: 2,
                                    )
                                  : Icon(
                                      Icons.arrow_forward,
                                      color: ether.fabIcon,
                                    ),
                            )
                          else
                            const SizedBox(width: 56, height: 56),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ether = OnboardingEtherTheme.of(context);
    final isDark = ether.isDark;

    return Stack(
      children: [
        _buildBackground(context, ether),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isDark)
                              Positioned(
                                top: 0,
                                child: IgnorePointer(
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.brandTeal
                                              .withValues(alpha: 0.15),
                                          blurRadius: 50,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final w = MediaQuery.of(context).size.width;
                                final scale =
                                    (w < 360 ? 0.8 : (w / 400).clamp(0.85, 1.1))
                                        .toDouble();
                                final outer = 320.0 * scale;
                                final mid = 270.0 * scale;
                                final inner = 224.0 * scale;
                                return SizedBox(
                                  width: outer,
                                  height: outer,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: outer,
                                        height: outer,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.brandTeal
                                                .withValues(alpha: 0.2),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: mid,
                                        height: mid,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.brandTeal
                                                .withValues(alpha: 0.1),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: inner,
                                        height: inner,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: isDark
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.brandTeal
                                                        .withValues(alpha: 0.25),
                                                    blurRadius: 50,
                                                    offset: const Offset(0, 20),
                                                  ),
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: const Color(0xFF005048)
                                                        .withValues(alpha: 0.08),
                                                    blurRadius: 24,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                        ),
                                        child: ClipOval(
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.asset(
                                                'assets/onboarding/welcome_pharma_hero.png',
                                                fit: BoxFit.cover,
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: isDark
                                                        ? [
                                                            AppColors
                                                                .etherDarkScaffold
                                                                .withValues(
                                                                    alpha: 0.8),
                                                            AppColors.transparent,
                                                            AppColors.brandTeal
                                                                .withValues(
                                                                    alpha: 0.2),
                                                          ]
                                                        : [
                                                            AppColors.brandMint
                                                                .withValues(
                                                                    alpha: 0.15),
                                                            AppColors.transparent,
                                                          ],
                                                    stops: isDark
                                                        ? const [0.0, 0.5, 1.0]
                                                        : const [0.0, 0.7],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isDark) ...[
                                        Positioned(
                                          top: 8,
                                          right: 48,
                                          child: _starWidget('★', 0.6),
                                        ),
                                        Positioned(
                                          bottom: 24,
                                          left: 32,
                                          child: _starWidget('✦', 0.4),
                                        ),
                                        Positioned(
                                          top: outer * 0.42,
                                          right: 16,
                                          child: _dotStar(0.5),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width < 360 ? 24 : 40,
                      ),
                      Text.rich(
                        TextSpan(
                          text: '¡Tu ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: _titleSize(context),
                            fontWeight: FontWeight.w800,
                            color: ether.textPrimary,
                            height: 1.25,
                          ),
                          children: [
                            TextSpan(
                              text: 'bienestar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: _titleSize(context),
                                fontWeight: FontWeight.w800,
                                color: ether.accent,
                                height: 1.25,
                              ),
                            ),
                            TextSpan(
                              text: ' comienza aquí!',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: _titleSize(context),
                                fontWeight: FontWeight.w800,
                                color: ether.textPrimary,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Explora farmacias y catálogo sin salir de casa.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: MediaQuery.of(context).size.width < 360
                              ? 14.0
                              : 16.0,
                          fontWeight: FontWeight.w500,
                          color: ether.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _titleSize(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 24.0;
    if (w < 400) return 26.0;
    return 28.0;
  }

  Widget _buildBackground(BuildContext context, OnboardingEtherTheme ether) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: ether.scaffoldDecoration(),
      child: ether.isDark
          ? Stack(
              children: [
                Positioned(
                  top: size.height * 0.1,
                  left: size.width * 0.15,
                  child: _starDot(0.4, 4),
                ),
                Positioned(
                  top: size.height * 0.25,
                  right: size.width * 0.1,
                  child: _starDot(0.3, 2),
                ),
                Positioned(
                  bottom: size.height * 0.3,
                  left: size.width * 0.05,
                  child: _starDot(0.2, 4),
                ),
                Positioned(
                  top: size.height * 0.05,
                  right: size.width * 0.35,
                  child: _starDot(0.4, 2, color: AppColors.brandTeal),
                ),
              ],
            )
          : null,
    );
  }

  Widget _starWidget(String char, double opacity) {
    return Text(
      char,
      style: TextStyle(
        color: AppColors.brandTeal.withValues(alpha: opacity),
        fontSize: 12,
      ),
    );
  }

  Widget _dotStar(double opacity) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.brandTeal.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _starDot(double opacity, double size, {Color? color}) {
    final c = color ?? AppColors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
