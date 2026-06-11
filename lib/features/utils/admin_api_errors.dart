import 'dart:convert';

import 'package:http/http.dart' as http;

/// Mensajes claros para respuestas fallidas del panel admin (`/api/admin/*`).
String adminHttpErrorMessage(String action, http.Response response) {
  try {
    if (response.body.isEmpty) {
      return '$action (${response.statusCode})';
    }
    final data = jsonDecode(response.body);
    if (data is Map) {
      switch (data['error_code']) {
        case 'ORDER_INVALID_TRANSITION':
        case 'ORDER_INVALID_STATUS':
          return data['message']?.toString() ??
              'No se puede cambiar el estado del pedido en esta transición.';
        case 'REVIEWS_NOT_FOUND':
          return data['message']?.toString() ?? 'Reseña no encontrada.';
        case 'REVIEWS_MODERATION_SCHEMA_MISSING':
          return data['message']?.toString() ??
              'Moderación de reseñas no disponible en este entorno.';
      }
      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first?.toString();
            if (first != null && first.trim().isNotEmpty) return first.trim();
          }
          if (value is String && value.trim().isNotEmpty) return value.trim();
        }
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
