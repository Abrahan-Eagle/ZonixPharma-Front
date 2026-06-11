import 'dart:convert';

import 'package:http/http.dart' as http;

/// Mensajes claros para respuestas fallidas de órdenes buyer (checkout, cancel, tracking).
String orderHttpErrorMessage(String action, http.Response response) {
  try {
    final data = jsonDecode(response.body);
    if (data is Map) {
      switch (data['error_code']) {
        case 'ORDER_TOTAL_MISMATCH':
          final recalculated = data['recalculated_total'];
          if (recalculated != null) {
            return 'El total cambió durante el checkout. Nuevo total: \$$recalculated';
          }
          return data['message']?.toString() ??
              'El total del pedido no coincide. Actualiza el carrito e intenta de nuevo.';
        case 'ORDER_IDEMPOTENCY_CONFLICT':
          return data['message']?.toString() ??
              'Se detectó un reintento inválido de compra. Intenta de nuevo.';
        case 'ORDER_MAX_CONCURRENT_OPEN':
          return data['message']?.toString() ??
              'Has alcanzado el máximo de pedidos activos. Cancela uno o espera a que finalice.';
        case 'ORDER_VALIDATION_ERROR':
          return data['message']?.toString() ?? 'Datos del pedido inválidos.';
        case 'ORDER_CREATE_ERROR':
          return data['message']?.toString() ??
              'No se pudo crear el pedido. Intenta de nuevo.';
        case 'ORDER_RX_PRESCRIPTION_REQUIRED':
          return data['message']?.toString() ??
              'Debes vincular una receta médica ya aprobada por esta farmacia antes de confirmar el pedido.';
        case 'ORDER_RX_PRESCRIPTION_INVALID':
          return data['message']?.toString() ??
              'La receta seleccionada no es válida para este pedido.';
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
