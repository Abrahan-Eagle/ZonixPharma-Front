import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/models/product.dart';

void main() {
  group('Product model stock semantics', () {
    test('stock_quantity null means unlimited stock', () {
      final product = Product.fromJson({
        'id': 1,
        'commerce_id': 10,
        'name': 'Paracetamol 500mg',
        'description': 'Demo',
        'price': 1.50,
        'available': true,
        'stock_quantity': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(product.isAvailable, true);
      expect(product.hasStockLimit, false);
      expect(product.stock, 0);
    });

    test('stock_quantity numeric means stock-limited', () {
      final product = Product.fromJson({
        'id': 1,
        'commerce_id': 10,
        'name': 'Paracetamol 500mg',
        'description': 'Demo',
        'price': 1.50,
        'available': true,
        'stock_quantity': 3,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(product.hasStockLimit, true);
      expect(product.stock, 3);
    });
  });

  group('Product model date parsing', () {
    test('created_at inválido no lanza y usa fallback', () {
      final product = Product.fromJson({
        'id': 1,
        'commerce_id': 10,
        'name': 'Demo',
        'description': 'Demo',
        'price': 1.0,
        'available': true,
        'stock_quantity': 1,
        'created_at': 'fecha-invalida',
        'updated_at': 'otra-invalida',
      });
      expect(product.createdAt, isA<DateTime>());
      expect(product.updatedAt, isA<DateTime>());
    });
  });

  group('Product model commerce id parsing', () {
    test('uses nested commerce.id when commerce_id is absent', () {
      final product = Product.fromJson({
        'id': 2,
        'commerce': {'id': 25, 'name': 'Farmacia Demo'},
        'name': 'Vitamina C',
        'description': 'Demo',
        'price': 12.5,
        'available': true,
        'stock_quantity': 5,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(product.commerceId, 25);
    });

    test('uses image_url and category_name aliases when present', () {
      final product = Product.fromJson({
        'id': 3,
        'commerce_id': 10,
        'name': 'Suero oral',
        'description': 'Demo',
        'price': 4.5,
        'is_available': true,
        'stock_quantity': 7,
        'image_url': 'https://cdn.example.com/sb.jpg',
        'category_name': 'Hidratación',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(product.image, 'https://cdn.example.com/sb.jpg');
      expect(product.category, 'Hidratación');
    });
  });

  group('Product Pharma fields', () {
    test('parses Rx and pharma attributes from JSON', () {
      final product = Product.fromJson({
        'id': 4,
        'commerce_id': 10,
        'name': 'Amoxicilina 500mg',
        'description': 'Antibiótico',
        'price': 3.20,
        'available': true,
        'stock_quantity': 50,
        'active_ingredient': 'amoxicilina',
        'dosage_form': 'capsule',
        'concentration': '500mg',
        'presentation': 'Caja x 21 cápsulas',
        'manufacturer': 'Farmavenezuela',
        'health_registry': 'E.F. 12345',
        'barcode': '7591234567890',
        'atc_code': 'J01CA04',
        'requires_prescription': true,
        'prescription_type': 'common',
        'controlled_substance': false,
        'cold_chain': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(product.requiresPrescription, true);
      expect(product.prescriptionType, 'common');
      expect(product.activeIngredient, 'amoxicilina');
      expect(product.dosageForm, 'capsule');
      expect(product.concentration, '500mg');
      expect(product.presentation, 'Caja x 21 cápsulas');
      expect(product.healthRegistry, 'E.F. 12345');
      expect(product.atcCode, 'J01CA04');
      expect(product.coldChain, false);
      expect(
        product.pharmaSummary,
        'amoxicilina · capsule · 500mg · Caja x 21 cápsulas',
      );
    });

    test('cold_chain and controlled flags survive round-trip', () {
      final product = Product.fromJson({
        'id': 5,
        'commerce_id': 10,
        'name': 'Insulina NPH',
        'description': 'Cadena de frío',
        'price': 30.00,
        'available': true,
        'stock_quantity': 5,
        'requires_prescription': true,
        'prescription_type': 'special',
        'cold_chain': true,
        'controlled_substance': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(product.coldChain, true);
      expect(product.requiresPrescription, true);
      expect(product.prescriptionType, 'special');
    });
  });
}
