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

    test('isPendingPayment incluye pending_prescription_validation', () {
      final rx = Order.fromJson({
        'id': 2,
        'user_id': 1,
        'commerce_id': 1,
        'order_number': 'RX-2',
        'status': 'pending_prescription_validation',
        'total': 10.0,
        'payment_method': '',
        'payment_status': 'pending',
        'delivery_address': '',
        'created_at': '2025-01-01T10:00:00.000Z',
        'updated_at': '2025-01-01T10:00:00.000Z',
        'items': <dynamic>[],
      });
      expect(rx.isPendingPayment, isTrue);
      expect(rx.isPendingPrescriptionValidation, isTrue);
    });

    test('parsea expires_at y requires_prescription', () {
      final deadline = DateTime.now().add(const Duration(minutes: 45));
      final o = Order.fromJson({
        'id': 4,
        'user_id': 1,
        'commerce_id': 1,
        'order_number': 'RX-4',
        'status': 'pending_prescription_validation',
        'total': 10.0,
        'payment_method': '',
        'payment_status': 'pending',
        'delivery_address': '',
        'created_at': '2025-01-01T10:00:00.000Z',
        'updated_at': '2025-01-01T10:00:00.000Z',
        'items': <dynamic>[],
        'requires_prescription': true,
        'expires_at': deadline.toIso8601String(),
      });
      expect(o.requiresPrescription, isTrue);
      expect(o.expiresAt, isNotNull);
      expect(o.hasRxUploadDeadline, isTrue);
      expect(o.isRxUploadExpired, isFalse);
      expect(o.rxTimeRemaining, isNotNull);
    });

    test('OrderItem.quantity parsea string numérico', () {
      final item = OrderItem.fromJson({
        'id': 1,
        'order_id': 2,
        'product_id': 3,
        'product_name': 'OTC',
        'price': '4.50',
        'quantity': '2',
        'total': 9,
      });
      expect(item.quantity, 2);
    });

    test('orderPayments ignora entradas no-map', () {
      final o = Order.fromJson({
        'id': 3,
        'user_id': 1,
        'commerce_id': 1,
        'order_number': 'P-3',
        'status': 'pending_payment',
        'total': 5.0,
        'payment_method': '',
        'payment_status': 'pending',
        'delivery_address': '',
        'created_at': '2025-01-01T10:00:00.000Z',
        'updated_at': '2025-01-01T10:00:00.000Z',
        'items': <dynamic>[],
        'order_payments': [
          {'type': 'food', 'amount': 5},
          'invalid',
          null,
        ],
      });
      expect(o.orderPayments.length, 1);
      expect(o.orderPayments.first['type'], 'food');
    });
  });
}

