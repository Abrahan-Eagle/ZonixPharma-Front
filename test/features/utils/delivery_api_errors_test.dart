import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/delivery_api_errors.dart';

void main() {
  group('deliveryHttpErrorMessage', () {
    test('mapea ORDER_ALREADY_ASSIGNED', () {
      final response = http.Response(
        '{"success":false,"error_code":"ORDER_ALREADY_ASSIGNED","message":"La orden ya fue asignada a otro repartidor."}',
        409,
      );
      expect(
        deliveryHttpErrorMessage('Aceptar pedido', response),
        'La orden ya fue asignada a otro repartidor.',
      );
    });

    test('usa message del backend sin error_code', () {
      final response = http.Response(
        '{"success":false,"message":"Código QR inválido"}',
        400,
      );
      expect(
        deliveryHttpErrorMessage('Verificar recogida', response),
        'Código QR inválido',
      );
    });

    test('fallback con status code', () {
      final response = http.Response('', 500);
      expect(
        deliveryHttpErrorMessage('Historial', response),
        'Historial (500)',
      );
    });
  });
}
