import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/app/main_router.dart';
import 'package:zonix/features/services/auth/google_sign_in_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/utils/auth_utils.dart';
import 'package:zonix/features/utils/user_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zonix/features/screens/onboarding/onboarding_screen.dart';
import 'package:zonix/features/utils/app_colors.dart';
import 'package:zonix/features/screens/restaurants/storefront_qr_scanner_page.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final ApiService apiService = ApiService();
final logger = Logger();

// Colores del template Stitch (basados en logo)
const Color _kBackgroundDark = AppColors.brandSurfaceDark;
const Color _kPrimary = AppColors.brandTeal;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GoogleSignInService googleSignInService = GoogleSignInService();
  bool isAuthenticated = false;
  GoogleSignInAccount? _currentUser;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      isAuthenticated = await AuthUtils.isAuthenticated();
      if (isAuthenticated) {
        _currentUser = await GoogleSignInService.getCurrentUser();
        if (_currentUser != null) {
          logger.i('Foto de usuario: ${_currentUser!.photoUrl}');
          await _storage.write(
              key: 'userPhotoUrl', value: _currentUser!.photoUrl);
          logger.i('Nombre de usuario: ${_currentUser!.displayName}');
          await _storage.write(
              key: 'displayName', value: _currentUser!.displayName);
        }
      }
    } catch (e) {
      logger.w('Error al verificar autenticación: $e');
      isAuthenticated = false;
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleSignIn() async {
    try {
      await GoogleSignInService.signInWithGoogle();
      _currentUser = await GoogleSignInService.getCurrentUser();
      setState(() {
        _loginError = null;
      });

      if (_currentUser != null) {
        final user = _currentUser!;
        await AuthUtils.saveUserName(user.displayName ?? '');
        await AuthUtils.saveUserEmail(user.email);
        final photoUrl = user.photoUrl;
        await AuthUtils.saveUserPhotoUrl(
            photoUrl?.isNotEmpty == true ? photoUrl : '');

        if (!mounted) return;

        final userProvider = context.read<UserProvider>();
        await userProvider.checkAuthentication();

        if (!mounted) return;

        if (!userProvider.isAuthenticated || userProvider.userId <= 0) {
          setState(() {
            _loginError = 'No se pudo validar la sesión con el servidor.';
          });
          return;
        }

        final onboardingCompleted = userProvider.completedOnboarding;

        if (!onboardingCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainRouter()),
          );
        }
      } else {
        logger.i('Inicio de sesión cancelado o fallido');
        if (!mounted) return;
        setState(() {
          _loginError = 'Inicio de sesión cancelado o fallido';
        });
      }
    } catch (e) {
      logger.e('Error durante el manejo del inicio de sesión: $e');
      if (!mounted) return;
      setState(() {
        _loginError = 'Error durante el inicio de sesión';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              // SliverFillRemaining evita overflow: con poco alto (teclado, pantalla chica)
              // el contenido hace scroll; con mucho espacio, el Spacer empuja el botón abajo.
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 64),
                          _buildLogoAndTitle(),
                          const SizedBox(height: 32),
                          const Spacer(),
                          _buildBottomContent(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: _kBackgroundDark,
      ),
      child: Stack(
        children: [
          // Gradiente espacial (como space-gradient del HTML)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.2,
                  colors: [
                    _kPrimary.withValues(alpha: 0.15),
                    AppColors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 1.2,
                  colors: [
                    _kPrimary.withValues(alpha: 0.1),
                    AppColors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Círculo decorativo inferior izquierdo (balance visual con el planeta)
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kPrimary.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: _kPrimary.withValues(alpha: 0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          // Acento decorativo superior derecho (sin logo duplicado)
          Positioned(
            top: -48,
            right: -48,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kPrimary.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Estrellas sutiles (capa estática, menos tema espacial)
          ..._loginStarLayer(),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/splash_logo_dark.png',
          height: 96,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Pide en tu farmacia de confianza, con la rapidez que mereces.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.brandMint.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_loginError != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _loginError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.statusError,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        // Botón Continuar con Google (pill-shaped)
        Semantics(
          button: true,
          label: 'Continuar con Google',
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Material(
              color: AppColors.transparent,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                onTap: _handleSignIn,
                borderRadius: BorderRadius.circular(28),
                splashColor: _kPrimary.withValues(alpha: 0.15),
                highlightColor: _kPrimary.withValues(alpha: 0.08),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppColors.white.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Continuar con Google',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.stitchTextDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const StorefrontQrScannerPage(),
              ),
            );
          },
          icon: Icon(
            Icons.qr_code_scanner,
            color: AppColors.brandMint.withValues(alpha: 0.85),
            size: 22,
          ),
          label: Text(
            'Escanear QR de una farmacia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.brandMint.withValues(alpha: 0.9),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Al continuar, aceptas nuestros Términos y Condiciones y Política de Privacidad.',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.brandMint.withValues(alpha: 0.55),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

List<Widget> _loginStarLayer() {
  const spots = <(double left, double top, double size, double opacity)>[
    (24, 48, 2, 0.35),
    (120, 32, 1, 0.25),
    (280, 72, 2, 0.3),
    (340, 160, 1, 0.2),
    (48, 200, 1, 0.25),
    (200, 120, 2, 0.28),
    (320, 280, 1, 0.22),
    (80, 360, 2, 0.3),
    (240, 400, 1, 0.25),
    (160, 520, 1, 0.2),
    (360, 480, 2, 0.28),
    (16, 640, 1, 0.22),
  ];
  return spots
      .map(
        (s) => Positioned(
          left: s.$1,
          top: s.$2,
          child: Opacity(
            opacity: s.$4,
            child: Container(
              width: s.$3,
              height: s.$3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      )
      .toList();
}
