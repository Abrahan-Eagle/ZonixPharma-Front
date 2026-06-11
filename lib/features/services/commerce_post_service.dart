import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zonix/config/app_config.dart';
import 'package:zonix/features/utils/commerce_api_errors.dart';
import 'package:zonix/helpers/auth_helper.dart';

/// Servicio para obtener publicaciones/posts de los comercios del usuario.
class CommercePostService {
  static String get baseUrl => AppConfig.apiUrl;

  /// GET /api/commerce/posts - Listar posts de los comercios del perfil
  static Future<List<Map<String, dynamic>>> getMyPosts({int page = 1, int perPage = 20}) async {
    final headers = await AuthHelper.getAuthHeaders();
    final uri = Uri.parse('$baseUrl/api/commerce/posts').replace(queryParameters: {
      'page': '$page',
      'per_page': '${perPage.clamp(1, 100)}',
    });
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final raw = data['data'];
        final list = raw is List
            ? raw
            : (raw is Map && raw['items'] is List ? raw['items'] as List : <dynamic>[]);
        return List<Map<String, dynamic>>.from(
          list.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
      return [];
    }
    throw Exception(
        commerceHttpErrorMessage('Error al obtener publicaciones', response));
  }
}
