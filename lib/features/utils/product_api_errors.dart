import 'dart:convert';

import 'package:http/http.dart' as http;

/// Mensajes claros para respuestas fallidas del catálogo buyer (productos / búsqueda).
String productHttpErrorMessage(String action, http.Response response) {
  try {
    final data = jsonDecode(response.body);
    if (data is Map) {
      switch (data['error_code']) {
        case 'PRODUCT_NOT_FOUND':
          return data['message']?.toString() ?? 'Producto no encontrado.';
      }
      for (final key in ['message', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
  } catch (_) {
    // Body no JSON.
  }
  return '$action (${response.statusCode})';
}
