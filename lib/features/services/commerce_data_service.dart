import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../helpers/auth_helper.dart';
import '../../config/app_config.dart';
import '../utils/commerce_api_errors.dart';

class CommerceDataService {
  static String get baseUrl => AppConfig.apiUrl;
  static final Logger _logger = Logger();

  /// Evita GET /api/commerce duplicados al arranque commerce (UserProvider + dashboard + orders).
  static Future<Map<String, dynamic>>? _getCommerceDataInFlight;

  // Obtener datos del comercio (usa GET /api/commerce para rol commerce)
  static Future<Map<String, dynamic>> getCommerceData() async {
    if (_getCommerceDataInFlight != null) return _getCommerceDataInFlight!;
    _getCommerceDataInFlight = _getCommerceDataImpl();
    try {
      return await _getCommerceDataInFlight!;
    } finally {
      _getCommerceDataInFlight = null;
    }
  }

  static Future<Map<String, dynamic>> _getCommerceDataImpl() async {
    try {
      final headers = await AuthHelper.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/commerce'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
        throw Exception('Respuesta inv?lida del servidor');
      } else if (response.statusCode == 404) {
        throw Exception('Comercio no encontrado');
      } else {
        throw Exception(commerceHttpErrorMessage(
            'Error al obtener datos del comercio', response));
      }
    } catch (e) {
      _logger.w('Error al obtener datos del comercio: $e');
      rethrow;
    }
  }

  // Actualizar datos del comercio (PUT /api/commerce)
  static Future<Map<String, dynamic>> updateCommerceData(Map<String, dynamic> data) async {
    final headers = await AuthHelper.getAuthHeaders();
    try {
      final body = <String, dynamic>{};
      if (data['business_name'] != null) body['business_name'] = data['business_name'];
      if (data['business_type'] != null) body['business_type'] = data['business_type'];
      if (data['address'] != null) body['address'] = data['address'];
      if (data['open'] != null) body['open'] = data['open'];
      if (data['schedule'] != null) {
        body['schedule'] = data['schedule'] is String
            ? data['schedule']
            : jsonEncode(data['schedule']);
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/commerce'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return Map<String, dynamic>.from(result);
      } else {
        throw Exception(commerceHttpErrorMessage(
            'Error al actualizar datos del comercio', response));
      }
    } catch (e) {
      _logger.w('Error al actualizar datos del comercio: $e');
      rethrow;
    }
  }

  // Actualizar datos de pago m?vil
  static Future<Map<String, dynamic>> updatePaymentData(Map<String, dynamic> data) async {
    final headers = await AuthHelper.getAuthHeaders();
    try {
      final profileResponse = await http.get(
        Uri.parse('$baseUrl/api/buyer/profiles'),
        headers: headers,
      );

      if (profileResponse.statusCode != 200) {
        throw Exception(commerceHttpErrorMessage(
            'Error al obtener perfil', profileResponse));
      }

      final profiles = jsonDecode(profileResponse.body);
      final userProfile = profiles.firstWhere(
        (profile) => profile['user_id'] != null,
        orElse: () => throw Exception('Perfil no encontrado'),
      );

      final profileId = userProfile['id'];

      final response = await http.post(
        Uri.parse('$baseUrl/api/buyer/profiles/$profileId'),
        headers: headers,
        body: jsonEncode({
          'commerce': {
            'mobile_payment_bank': data['bank'],
            'mobile_payment_id': data['payment_id'],
            'mobile_payment_phone': data['payment_phone'],
          },
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception(commerceHttpErrorMessage(
            'Error al actualizar datos de pago', response));
      }
    } catch (e) {
      _logger.w('Error al actualizar datos de pago: $e');
      rethrow;
    }
  }

  /// Crea comercio cuando el perfil ya existe (onboarding comercio).
  /// Usa POST /api/profiles/add-commerce y devuelve data.id para vincular la direcci?n.
  static Future<Map<String, dynamic>> createCommerceForExistingProfile(
    int profileId,
    Map<String, dynamic> data,
  ) async {
    final headers = await AuthHelper.getAuthHeaders();
    final body = Map<String, dynamic>.from(data)..['profile_id'] = profileId;
    final response = await http.post(
      Uri.parse('$baseUrl/api/profiles/add-commerce'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      final result = jsonDecode(response.body);
      return result;
    }
    if (response.statusCode == 409) {
      final decoded = jsonDecode(response.body);
      if (decoded['data']?['id'] != null) {
        return {'success': true, 'data': decoded['data']};
      }
    }
    _logger.e('add-commerce fall?: ${response.statusCode} body: ${response.body.length > 300 ? response.body.substring(0, 300) : response.body}');
    String msg = 'Error al crear comercio';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        msg = decoded['message'].toString();
        if (decoded['errors'] != null && decoded['errors'] is Map) {
          final errs = (decoded['errors'] as Map).values;
          if (errs.isNotEmpty) msg = '$msg ${errs.first}';
        }
      }
    } catch (e) {
      debugPrint('[CommerceDataService] error parse: $e');
    }
    throw Exception('$msg (${response.statusCode})');
  }

  // Crear nuevo comercio (perfil + comercio en una llamada; para flujos sin perfil previo)
  static Future<Map<String, dynamic>> createCommerce(Map<String, dynamic> data) async {
    final headers = await AuthHelper.getAuthHeaders();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/profiles/commerce'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        final result = jsonDecode(response.body);
        return result;
      } else {
        throw Exception(commerceHttpErrorMessage(
            'Error al crear comercio', response));
      }
    } catch (e) {
      _logger.w('Error al crear comercio: $e');
      rethrow;
    }
  }

  /// Subir imagen del comercio al servidor.
  /// Usa POST /api/commerce/logo con multipart/form-data.
  /// Retorna la URL de la imagen subida.
  static Future<String> uploadCommerceImage(String imagePath) async {
    if (imagePath.isEmpty) {
      throw Exception('Ruta de imagen vac?a');
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('El archivo de imagen no existe');
    }

    final headers = await AuthHelper.getAuthHeaders();
    // Para multipart no incluir Content-Type - el request lo establece con boundary
    headers.remove('Content-Type');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/commerce/logo'),
    );

    request.headers.addAll(headers);
    request.files.add(
      await http.MultipartFile.fromPath('image', imagePath),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final url = data['data']['image'] ?? data['data']['url'];
        if (url != null && url is String) return url;
      }
      throw Exception(data['message'] ?? 'Respuesta inv?lida del servidor');
    } else if (response.statusCode == 404) {
      throw Exception('Comercio no encontrado');
    } else if (response.statusCode == 422) {
      try {
        final data = jsonDecode(response.body);
        final errors = data['errors'];
        if (errors != null && errors is Map) {
          final imageErrors = errors['image'];
          if (imageErrors != null && imageErrors is List && imageErrors.isNotEmpty) {
            throw Exception(imageErrors.first.toString());
          }
        }
      } catch (e) {
        if (e is Exception) rethrow;
      }
      throw Exception('Imagen no v?lida. Use JPEG, PNG o JPG (m?x. 2MB).');
    } else {
      throw Exception(
          commerceHttpErrorMessage('Error al subir imagen', response));
    }
  }
} 