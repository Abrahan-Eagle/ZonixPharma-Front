import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/models/medicine_lot.dart';

void main() {
  group('MedicineLot model', () {
    test('isExpired detects past dates', () {
      final lot = MedicineLot.fromJson({
        'id': 1,
        'product_id': 1,
        'lot_number': 'L-0001',
        'expiry_date':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'quantity_received': 100,
        'quantity_available': 50,
      });
      expect(lot.isExpired, true);
    });

    test('isExpiringSoon true within window', () {
      final lot = MedicineLot.fromJson({
        'id': 2,
        'product_id': 1,
        'lot_number': 'L-0002',
        'expiry_date':
            DateTime.now().add(const Duration(days: 20)).toIso8601String(),
        'quantity_received': 50,
        'quantity_available': 50,
      });
      expect(lot.isExpiringSoon(days: 60), true);
      expect(lot.isExpiringSoon(days: 7), false);
    });
  });
}
