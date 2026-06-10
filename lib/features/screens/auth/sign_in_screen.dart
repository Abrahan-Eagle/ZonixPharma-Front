import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

// Tokens Clinical Ether (stitch_zonix_pharma/DESIGN.md + templates HTML)
const Color _kLoginBackgroundDark = Color(0xFF071326);
const Color _kLoginBackgroundLight = Color(0xFFF4F9F8);
const Color _kLoginOnSurface = Color(0xFFD7E3FD);
const Color _kLoginOnSurfaceVariant = Color(0xFFBCC9C6);
const Color _kLoginSurfaceContainerHigh = Color(0xFF1E2A3E);
const Color _kLoginOnPrimary = Color(0xFF003732);
const Color _kLoginOnPrimaryContainer = Color(0xFF005048);
const Color _kLoginOutline = Color(0xFF879390);
const Color _kLoginOutlineVariant = Color(0xFF3D4947);
const String _kLoginCapsuleIcon =
    'assets/LogosZonixPharma/ZonixPharma_05.png';

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

  bool _isDark(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: isDark ? _kLoginBackgroundDark : _kLoginBackgroundLight,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: _buildLogoAndTitle(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 64),
                        child: _buildBottomContent(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle(BuildContext context) {
    final isDark = _isDark(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? AppColors.brandTeal.withValues(alpha: 0.05)
                    : _kLoginOnPrimaryContainer.withValues(alpha: 0.08),
                blurRadius: isDark ? 64 : 32,
                offset: isDark ? Offset.zero : const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Image.asset(
              _kLoginCapsuleIcon,
              width: 92,
              height: 92,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Image.asset(
              isDark
                  ? 'assets/images/brand-android-dark.png'
                  : 'assets/images/brand-android.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 288),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Pide en tu farmacia de confianza, con la rapidez que mereces.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 24 / 16,
                color: isDark
                    ? _kLoginOnSurface.withValues(alpha: 0.6)
                    : _kLoginOnPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomContent(BuildContext context) {
    final isDark = _isDark(context);

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
                splashColor: AppColors.brandTeal.withValues(alpha: 0.12),
                highlightColor: AppColors.brandTeal.withValues(alpha: 0.06),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isDark
                        ? _kLoginSurfaceContainerHigh
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _kLoginOutline.withValues(
                        alpha: isDark ? 0.1 : 0.3,
                      ),
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _GoogleLogoIcon(size: 24),
                      const SizedBox(width: 16),
                      Text(
                        'Continuar con Google',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 28 / 22,
                          color: isDark
                              ? _kLoginOnSurface
                              : _kLoginOnPrimaryContainer,
                        ),
                      ),
                    ],
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
          style: TextButton.styleFrom(
            foregroundColor: isDark
                ? AppColors.brandTeal
                : _kLoginOnPrimaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          icon: Icon(
            Icons.qr_code_scanner,
            size: 20,
            color: isDark
                ? AppColors.brandTeal
                : _kLoginOnPrimaryContainer,
          ),
          label: Text(
            'Escanear QR de una farmacia',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 24 / 16,
              letterSpacing: 0.1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 288),
          child: Text(
            'Al continuar, aceptas nuestros Términos y Condiciones y Política de Privacidad.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              letterSpacing: 0.5,
              color: isDark
                  ? _kLoginOnSurfaceVariant.withValues(alpha: 0.4)
                  : _kLoginOutlineVariant.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }
}

/// Logo Google multicolor (SVG oficial template Stitch HTML).
class _GoogleLogoIcon extends StatelessWidget {
  const _GoogleLogoIcon({this.size = 24});

  final double size;

  static const String _svg = '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
<path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
<path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
<path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
</svg>''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: size,
      height: size,
    );
  }
}
