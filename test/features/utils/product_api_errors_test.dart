import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/product_api_errors.dart';

void main() {
  group('productHttpErrorMessage', () {
    test('usa message del backend', () {
      final response = http.Response(
        '{"success":false,"message":"Producto no encontrado"}',
        404,
      );
      expect(
        productHttpErrorMessage('Producto', response),
        'Producto no encontrado',
      );
    });

    test('fallback con status code', () {
      final response = http.Response('', 500);
      expect(
        productHttpErrorMessage('Catálogo', response),
        'Catálogo (500)',
      );
    });
  });
}
