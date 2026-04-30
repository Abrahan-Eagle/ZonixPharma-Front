import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/models/cart_item.dart';

void main() {
  group('CartItem.copyWith', () {
    test('preserva flags farmacéuticos al cambiar solo quantity', () {
      final base = CartItem(
        id: 10,
        nombre: 'Ibuprofeno',
        precio: 5.0,
        quantity: 1,
        requiresPrescription: true,
        prescriptionType: 'common',
        controlledSubstance: true,
        coldChain: true,
      );
      final updated = base.copyWith(quantity: 3);
      expect(updated.quantity, 3);
      expect(updated.requiresPrescription, true);
      expect(updated.prescriptionType, 'common');
      expect(updated.controlledSubstance, true);
      expect(updated.coldChain, true);
    });
  });
}
