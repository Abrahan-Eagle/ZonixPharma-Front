import 'dart:convert';

import 'package:http/http.dart' as http;

/// Mensajes claros para respuestas fallidas de recetas (buyer + pharmacist).
String prescriptionHttpErrorMessage(String action, http.Response response) {
  try {
    final data = jsonDecode(response.body);
    if (data is Map) {
      switch (data['error_code']) {
        case 'PHARMACIST_LICENSE_INVALID':
          return data['message']?.toString() ??
              'Tu licencia colegiada no está verificada o ha vencido.';
        case 'PRESCRIPTION_NOT_ALLOWED_FOR_STATUS':
          return data['message']?.toString() ??
              'Solo puedes subir receta mientras el pedido espera validación.';
        case 'PRESCRIPTION_ALREADY_PROCESSED':
          return data['message']?.toString() ??
              'Esta receta ya fue procesada y no se puede eliminar.';
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

/// Alias histórico — preferir [prescriptionHttpErrorMessage].
String pharmacistHttpErrorMessage(String action, http.Response response) =>
    prescriptionHttpErrorMessage(action, response);
