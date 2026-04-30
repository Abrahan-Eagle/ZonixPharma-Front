import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/models/order.dart';

void main() {
  group('canonicalOrderStatus', () {
    test('aliases Rx se normalizan a pending_prescription_validation', () {
      expect(canonicalOrderStatus('awaiting_prescription'), 'pending_prescription_validation');
      expect(canonicalOrderStatus('rx_pending'), 'pending_prescription_validation');
      expect(canonicalOrderStatus('pending_prescription_validation'), 'pending_prescription_validation');
    });
  });

  group('Order.fromJson Rx', () {
    test('parsea status pendiente de receta y prescription_id', () {
      final o = Order.fromJson({
        'id': 1,
        'user_id': 2,
        'commerce_id': 3,
        'order_number': 'RX-1',
        'status': 'pending_prescription_validation',
        'total': 12.0,
        'payment_method': 'transfer',
        'payment_status': 'pending',
        'delivery_address': 'Calle 1',
        'created_at': '2025-01-01T10:00:00.000Z',
        'updated_at': '2025-01-01T10:00:00.000Z',
        'items': <dynamic>[],
        'prescription_id': 42,
      });
      expect(o.status, 'pending_prescription_validation');
      expect(o.statusText, 'Esperando validación de receta');
      expect(o.statusColor, '#56C7B8');
      expect(o.prescriptionId, 42);
    });
  });
}
