import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:zonix/features/services/auth/api_service.dart';
import 'package:zonix/features/utils/auth_utils.dart';

const FlutterSecureStorage _storage = FlutterSecureStorage();
final Logger logger = Logger();
final ApiService _apiService = ApiService();

GoogleSignIn? _googleSignInCached;

/// Misma instancia tras [dotenv.load] para que `serverClientId` (id_token) sea coherente con signOut.
GoogleSignIn _googleSignIn() {
  _googleSignInCached ??= GoogleSignIn(
    scopes: const [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
    serverClientId: _readGoogleSignInServerClientId(),
  );
  return _googleSignInCached!;
}

/// ID cliente OAuth **Web** (mismo valor que `GOOGLE_CLIENT_ID` en Laravel si validáis `aud` del id_token).
String? _readGoogleSignInServerClientId() {
  if (!dotenv.isInitialized) return null;
  final v = dotenv.env['GOOGLE_SIGN_IN_SERVER_CLIENT_ID']?.trim();
  if (v == null || v.isEmpty) return null;
  return v;
}

void _logGoogleSignInDeveloperHint(Object error) {
  if (!kDebugMode) return;
  final webIdSet = dotenv.isInitialized &&
      (dotenv.env['GOOGLE_SIGN_IN_SERVER_CLIENT_ID']?.trim().isNotEmpty ?? false);
  logger.i(
    'Google Sign-In debug: GOOGLE_SIGN_IN_SERVER_CLIENT_ID '
    '${webIdSet ? "definido (debe ser cliente OAuth Web, no el del JSON Android)" : "no definido"}.',
  );
  if (error is! PlatformException) return;
  if (error.code != 'sign_in_failed') return;
  final msg = error.message ?? '';
  if (!msg.contains('10')) return;
  logger.w(
    'ApiException 10 (DEVELOPER_ERROR): en Firebase añade SHA-1 y SHA-256 del keystore de firma para '
    'com.zonix.eats (applicationId Android actual), descarga google-services.json de nuevo; en Google Cloud verifica el cliente OAuth '
    'Android. Ejecuta: bash android/print_firebase_registration_sha.sh. Checklist en .env.example.',
  );
}

class GoogleSignInService {
  // Método para iniciar sesión con Google
  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final user = await _googleSignIn().signIn();
      if (user == null) {
        logger.i('Inicio de sesión cancelado');
        return null; // Retorna null si el usuario cancela la autenticación
      }

      final googleAuth = await user.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      final backendToken = (idToken != null && idToken.isNotEmpty)
          ? idToken
          : accessToken;
      if (backendToken == null || backendToken.isEmpty) {
        logger.e('Error: tokens Google ausentes, no se puede autenticar con backend');
        await AuthUtils.clearTokens();
        return null;
      }
      final usingIdToken = idToken != null && idToken.isNotEmpty;
      logger.i(
        usingIdToken
            ? 'Google auth: usando idToken para backend'
            : 'Google auth: idToken ausente, usando accessToken fallback para backend',
      );

      // Guardar tokens de Google (id token) solo como referencia local temporal.
      if (idToken != null && idToken.isNotEmpty) {
        await _storage.write(key: 'google_idToken', value: idToken);
      }

      // Obtener datos del perfil del usuario utilizando access token.
      // Para backend SIEMPRE usamos idToken verificado por Google tokeninfo.
      if (accessToken == null || accessToken.isEmpty) {
        logger.e('Error: Google accessToken ausente para consultar userinfo');
        await AuthUtils.clearTokens();
        return null;
      }

      final profileResponse = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        logger.i('Perfil Google obtenido OK');

        // Enviar el token al backend
        final processedResult = jsonEncode({
          'token': backendToken,
          'profile': profileData,
        });

        final response = await _apiService.sendTokenToBackend(processedResult);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>?;
          if (data == null) {
            logger.e('Backend devolvió respuesta vacía');
            return null;
          }
          // Backend puede devolver { data: { user, token } } o { token } directo
          final inner = data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
          final token = inner['token']?.toString();
          final rawExpiresIn = data['expires_in'];
          final expiresIn = (rawExpiresIn is int && rawExpiresIn > 0) ? rawExpiresIn : 3600;
          if (token == null || token.isEmpty) {
            logger.e('Backend no devolvió token');
            return null;
          }
          await AuthUtils.saveToken(token, expiresIn);
          final role = inner['user']?['role']?.toString() ?? data['user']?['role']?.toString() ?? 'users';
          await _storage.write(key: 'role', value: role);
          logger.i('Token guardado correctamente con su expiración.');
          return user; // Retorna el usuario autenticado
        } else {
          logger.e('Error al enviar el token al backend: ${response.statusCode}');
          await AuthUtils.clearTokens();
          return null; // Retorna null si hay error al enviar el token al backend
        }
      } else {
        logger.e('Error al obtener los datos del perfil: ${profileResponse.statusCode}');
        await AuthUtils.clearTokens();
        return null; // Retorna null si no se pueden obtener los datos del perfil
      }
    } catch (error) {
      logger.e('Error durante el inicio de sesión con Google: $error');
      _logGoogleSignInDeveloperHint(error);
      await AuthUtils.clearTokens();
      return null; // Retorna null si hay una excepción
    }
  }

  // Método para obtener el usuario autenticado actualmente
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn().signInSilently();
      if (user != null) {
        logger.i('Usuario autenticado silenciosamente');
        return user; // Devuelve el usuario autenticado directamente
      } else {
        logger.i('No hay usuario autenticado actualmente.');
      }
    } catch (error) {
      logger.e('Error al intentar autenticar de forma silenciosa: $error');
      _logGoogleSignInDeveloperHint(error);
      return null;
    }
    return null; // Devuelve null si no hay usuario autenticado
  }

  // Método para cerrar sesión
  /// Cierra sesión Google usando la misma configuración que el sign-in (p. ej. [user_provider]).
  static Future<void> signOutGoogle() async {
    try {
      await _googleSignIn().signOut();
    } catch (error) {
      logger.e('Error al cerrar sesión Google: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn().signOut();
      await _storage.deleteAll(); // Eliminar los tokens almacenados
      logger.i('Sesión cerrada exitosamente.');
    } catch (error) {
      logger.e('Error al cerrar sesión: $error');
    }
  }

  // Inicialización: Verifica si hay un usuario autenticado silenciosamente al iniciar la app
  Future<void> initAuth() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      logger.i('Usuario autenticado automáticamente');
    } else {
      logger.i('No se detectó ningún usuario autenticado. Requiere inicio de sesión.');
    }
  }
}
