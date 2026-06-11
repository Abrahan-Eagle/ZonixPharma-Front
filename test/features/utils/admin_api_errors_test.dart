import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/admin_api_errors.dart';

void main() {
  group('adminHttpErrorMessage', () {
    test('mapea ORDER_INVALID_TRANSITION', () {
      final response = http.Response(
        '{"success":false,"error_code":"ORDER_INVALID_TRANSITION","message":"Transición no permitida"}',
        409,
      );
      expect(
        adminHttpErrorMessage('Estado del pedido', response),
        'Transición no permitida',
      );
    });

    test('extrae errores de validación Laravel', () {
      final response = http.Response(
        '{"message":"The given data was invalid.","errors":{"admin_notes":["The admin notes field is required."]}}',
        422,
      );
      expect(
        adminHttpErrorMessage('Resolver disputa', response),
        'The admin notes field is required.',
      );
    });

    test('fallback con status code', () {
      final response = http.Response('', 500);
      expect(
        adminHttpErrorMessage('Estadísticas', response),
        'Estadísticas (500)',
      );
    });
  });
}
