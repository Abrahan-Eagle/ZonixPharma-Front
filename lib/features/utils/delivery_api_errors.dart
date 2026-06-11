import 'dart:convert';

import 'package:http/http.dart' as http;

/// Mensajes claros para respuestas fallidas del panel repartidor (`/api/delivery/*`).
String deliveryHttpErrorMessage(String action, http.Response response) {
  try {
    final data = jsonDecode(response.body);
    if (data is Map) {
      switch (data['error_code']) {
        case 'ORDER_ACCEPT_INVALID_STATUS':
          return data['message']?.toString() ??
              'Solo puedes aceptar pedidos en preparación o listos para recoger.';
        case 'ORDER_ALREADY_ASSIGNED':
          return data['message']?.toString() ??
              'Este pedido ya fue asignado a otro repartidor.';
        case 'ORDER_FORBIDDEN':
          return data['message']?.toString() ??
              'No tienes permiso para operar este pedido.';
        case 'ORDER_INVALID_TRANSITION':
        case 'ORDER_INVALID_STATUS':
          return data['message']?.toString() ??
              'No se puede cambiar el estado del pedido en este momento.';
        case 'DELIVERY_HISTORY_FETCH_FAILED':
          return data['message']?.toString() ??
              'No se pudo cargar el historial de entregas.';
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
