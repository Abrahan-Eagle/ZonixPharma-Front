import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zonix/config/app_config.dart';

/// Políticas Pharma públicas (GET /api/public/pharma-policy).
class PharmaPolicyService {
  PharmaPolicyService._();

  static bool? _blockRxWithoutPrescription;
  static bool _loading = false;

  /// Modo estricto: checkout Rx exige receta aprobada antes de crear orden.
  static Future<bool> blockRxWithoutPrescription({bool forceRefresh = false}) async {
    if (!forceRefresh && _blockRxWithoutPrescription != null) {
      return _blockRxWithoutPrescription!;
    }
    if (_loading) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return _blockRxWithoutPrescription ?? false;
    }
    _loading = true;
    try {
      final url = Uri.parse('${AppConfig.apiUrl}/api/pharma-policy');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['success'] == true && data['data'] is Map) {
          final flags = data['data'] as Map;
          _blockRxWithoutPrescription =
              flags['block_rx_without_prescription'] == true;
          return _blockRxWithoutPrescription!;
        }
      }
    } catch (_) {
      // Fallback permisivo (MVP default).
    } finally {
      _loading = false;
    }
    _blockRxWithoutPrescription ??= false;
    return _blockRxWithoutPrescription!;
  }

  /// Solo tests.
  static void resetCacheForTesting() {
    _blockRxWithoutPrescription = null;
    _loading = false;
  }

  /// Solo tests: fija cache sin HTTP (p. ej. widget test modo estricto).
  static void seedCacheForTesting({required bool blockRx}) {
    _blockRxWithoutPrescription = blockRx;
    _loading = false;
  }
}
