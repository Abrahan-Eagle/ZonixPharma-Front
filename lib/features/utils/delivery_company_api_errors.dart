import 'dart:convert';

import 'package:http/http.dart' as http;

/// Mensajes claros para respuestas fallidas de empresa delivery (`/api/delivery-company/*`).
String deliveryCompanyHttpErrorMessage(String action, http.Response response) {
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
              'No se puede operar este pedido en su estado actual.';
        case 'ORDER_ALREADY_ASSIGNED':
          return data['message']?.toString() ??
              'Este pedido ya tiene un repartidor asignado.';
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
