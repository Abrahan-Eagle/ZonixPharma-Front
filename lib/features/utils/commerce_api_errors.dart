import 'dart:convert';

import 'package:http/http.dart' as http;

/// Convierte respuestas HTTP fallidas del panel commerce en mensajes claros.
///
/// El middleware backend `commerce.approved` responde 403 con `error_code`
/// (`COMMERCE_PENDING_APPROVAL` / `COMMERCE_PROFILE_REQUIRED`) mientras la
/// farmacia no esté aprobada; este helper prioriza el `message` del backend
/// sobre el código HTTP crudo para que la UI nunca muestre "Error: 403".
String commerceHttpErrorMessage(String action, http.Response response) {
  try {
    final data = jsonDecode(response.body);
    if (data is Map) {
      switch (data['error_code']) {
        case 'COMMERCE_PENDING_APPROVAL':
          return data['message']?.toString() ??
              'Tu farmacia está pendiente de aprobación por el administrador.';
        case 'COMMERCE_PROFILE_REQUIRED':
          return data['message']?.toString() ??
              'Debes registrar tu farmacia antes de acceder al panel comercial.';
      }
      for (final key in ['message', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
  } catch (_) {
    // Body no JSON: usar el mensaje genérico con el status code.
  }
  return '$action (${response.statusCode})';
}
