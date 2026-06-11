import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../utils/commerce_context.dart';

class CommerceDeliveryZoneService {
  static String get baseUrl => AppConfig.apiUrl;

  static const String _unavailableCrudMessage =
      'La gestión de zonas de entrega desde el panel comercio no está '
      'disponible en esta versión. Usa la configuración de ubicación del '
      'sistema o contacta al administrador.';

  static Never _throwUnavailable() {
    throw UnsupportedError(_unavailableCrudMessage);
  }

  // GET /api/location/delivery-zones — zonas activas (lectura)
  static Future<List<Map<String, dynamic>>> getDeliveryZones({
    String? status,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final headers = await CommerceContext.getAuthHeaders();
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final uri = Uri.parse('$baseUrl/api/location/delivery-zones')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] is List) {
            return List<Map<String, dynamic>>.from(data['data'] as List);
          }
          if (data['data'] is List) {
            return List<Map<String, dynamic>>.from(data['data'] as List);
          }
        }
        return [];
      } else {
        throw Exception(
            'Error al obtener zonas de delivery: ${response.statusCode}');
      }
    } catch (e) {
      if (e is UnsupportedError) rethrow;
      throw Exception('Error al obtener zonas de delivery: $e');
    }
  }

  static Future<Map<String, dynamic>> getDeliveryZone(int id) async =>
      _throwUnavailable();

  static Future<Map<String, dynamic>> createDeliveryZone(
          Map<String, dynamic> data) async =>
      _throwUnavailable();

  static Future<Map<String, dynamic>> updateDeliveryZone(
          int id, Map<String, dynamic> data) async =>
      _throwUnavailable();

  static Future<void> deleteDeliveryZone(int id) async => _throwUnavailable();

  static Future<Map<String, dynamic>> toggleDeliveryZoneStatus(int id) async =>
      _throwUnavailable();

  static Future<Map<String, dynamic>> getDeliveryZoneStats() async =>
      _throwUnavailable();

  static Future<Map<String, dynamic>> checkDeliveryZone(
          double lat, double lng) async =>
      _throwUnavailable();

  static Future<Map<String, dynamic>> calculateDeliveryFee(
          double lat, double lng) async =>
      _throwUnavailable();

  static Future<List<Map<String, dynamic>>> getActiveDeliveryZones() async {
    return getDeliveryZones(status: 'active');
  }

  static Future<List<Map<String, dynamic>>> getInactiveDeliveryZones() async {
    return getDeliveryZones(status: 'inactive');
  }

  static Future<List<Map<String, dynamic>>> getDeliveryZonesByRadius(
          double radius) async =>
      getDeliveryZones();

  static Future<List<Map<String, dynamic>>> getDeliveryZonesByFee(
          double minFee, double maxFee) async =>
      getDeliveryZones();
}
