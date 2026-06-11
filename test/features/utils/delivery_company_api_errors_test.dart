import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/delivery_company_api_errors.dart';

void main() {
  group('deliveryCompanyHttpErrorMessage', () {
    test('usa message del backend en asignación duplicada', () {
      final response = http.Response(
        '{"success":false,"message":"La orden ya tiene un repartidor asignado"}',
        409,
      );
      expect(
        deliveryCompanyHttpErrorMessage('Asignar pedido', response),
        'La orden ya tiene un repartidor asignado',
      );
    });

    test('fallback con status code', () {
      final response = http.Response('', 500);
      expect(
        deliveryCompanyHttpErrorMessage('Dashboard', response),
        'Dashboard (500)',
      );
    });
  });
}
