import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/utils/storefront_qr_parser.dart';

void main() {
  group('StorefrontQrParser · Pharma deep links', () {
    test('zonix://pharmacy/{id} se interpreta como commerce', () {
      final result = StorefrontQrParser.parse('zonix://pharmacy/42');
      expect(result.kind, StorefrontQrKind.commerce);
      expect(result.commerceId, 42);
    });

    test('zonix://restaurant/{id} legacy sigue funcionando', () {
      final result = StorefrontQrParser.parse('zonix://restaurant/42');
      expect(result.kind, StorefrontQrKind.commerce);
      expect(result.commerceId, 42);
    });

    test('https con /r/{id} se interpreta como commerce', () {
      final result = StorefrontQrParser.parse('https://zonixpharma.com/r/15');
      expect(result.kind, StorefrontQrKind.commerce);
      expect(result.commerceId, 15);
    });

    test('zonix://pickup/{...} es order QR', () {
      final result = StorefrontQrParser.parse('zonix://pickup/abc123');
      expect(result.kind, StorefrontQrKind.orderPickupOrDelivery);
    });

    test('zonix://delivery/{...} es order QR', () {
      final result = StorefrontQrParser.parse('zonix://delivery/abc123');
      expect(result.kind, StorefrontQrKind.orderPickupOrDelivery);
    });

    test('texto vacío devuelve invalid', () {
      expect(StorefrontQrParser.parse('').kind, StorefrontQrKind.invalid);
      expect(StorefrontQrParser.parse('   ').kind, StorefrontQrKind.invalid);
    });

    test('id inválido devuelve invalid', () {
      expect(StorefrontQrParser.parse('zonix://pharmacy/abc').kind,
          StorefrontQrKind.invalid);
      expect(StorefrontQrParser.parse('zonix://pharmacy/0').kind,
          StorefrontQrKind.invalid);
    });

    test('host desconocido devuelve invalid', () {
      expect(StorefrontQrParser.parse('zonix://store/10').kind,
          StorefrontQrKind.invalid);
    });
  });
}
