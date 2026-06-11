import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/order_api_errors.dart';

void main() {
  group('orderHttpErrorMessage', () {
    test('ORDER_MAX_CONCURRENT_OPEN', () {
      final response = http.Response(
        '{"success":false,"message":"Máximo de pedidos activos","error_code":"ORDER_MAX_CONCURRENT_OPEN"}',
        422,
      );
      expect(
        orderHttpErrorMessage('Crear orden', response),
        'Máximo de pedidos activos',
      );
    });

    test('ORDER_TOTAL_MISMATCH con recalculated_total', () {
      final response = http.Response(
        '{"success":false,"error_code":"ORDER_TOTAL_MISMATCH","recalculated_total":42.5}',
        409,
      );
      expect(
        orderHttpErrorMessage('Checkout', response),
        'El total cambió durante el checkout. Nuevo total: \$42.5',
      );
    });

    test('usa message genérico', () {
      final response = http.Response(
        '{"success":false,"message":"Orden no encontrada"}',
        404,
      );
      expect(orderHttpErrorMessage('Orden', response), 'Orden no encontrada');
    });
  });
}
