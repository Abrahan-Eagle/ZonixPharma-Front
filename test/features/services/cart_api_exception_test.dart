import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/services/cart_service.dart';

void main() {
  group('CartApiException', () {
    test('flags OUT_OF_STOCK y COMMERCE_CLOSED', () {
      final stock = CartApiException(
        message: 'Sin stock',
        errorCode: 'OUT_OF_STOCK',
        statusCode: 422,
      );
      final closed = CartApiException(
        message: 'Farmacia cerrada',
        errorCode: 'COMMERCE_CLOSED',
        statusCode: 422,
      );
      expect(stock.isOutOfStock, isTrue);
      expect(stock.isCommerceClosed, isFalse);
      expect(closed.isCommerceClosed, isTrue);
    });
  });
}
