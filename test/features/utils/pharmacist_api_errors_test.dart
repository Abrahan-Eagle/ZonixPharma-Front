import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:zonix/features/utils/pharmacist_api_errors.dart';

void main() {
  group('pharmacistHttpErrorMessage', () {
    test('prioriza PHARMACIST_LICENSE_INVALID', () {
      final response = http.Response(
        '{"success":false,"message":"Licencia no verificada","error_code":"PHARMACIST_LICENSE_INVALID"}',
        403,
      );
      expect(
        pharmacistHttpErrorMessage('Aprobar', response),
        'Licencia no verificada',
      );
    });

    test('PRESCRIPTION_ALREADY_PROCESSED', () {
      final response = http.Response(
        '{"success":false,"message":"No se puede eliminar","error_code":"PRESCRIPTION_ALREADY_PROCESSED"}',
        422,
      );
      expect(
        prescriptionHttpErrorMessage('Eliminar', response),
        'No se puede eliminar',
      );
    });

    test('usa message del backend', () {
      final response = http.Response(
        '{"success":false,"message":"Receta no encontrada."}',
        404,
      );
      expect(
        pharmacistHttpErrorMessage('Receta', response),
        'Receta no encontrada.',
      );
    });
  });
}
