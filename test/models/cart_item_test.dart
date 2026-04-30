import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/models/cart_item.dart';

void main() {
  group('CartItem', () {
    test('Crea item de carrito con datos básicos', () {
      final item = CartItem(
        id: 1,
        nombre: 'Paracetamol 500mg',
        precio: 1.50,
        quantity: 2,
        imagen: 'https://example.com/p.jpg',
      );

      expect(item.id, 1);
      expect(item.nombre, 'Paracetamol 500mg');
      expect(item.precio, 1.50);
      expect(item.quantity, 2);
      expect(item.imagen, 'https://example.com/p.jpg');
      expect(item.requiresPrescription, false);
      expect(item.coldChain, false);
      expect(item.controlledSubstance, false);
    });

    test('Crea item de carrito desde JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Paracetamol 500mg',
        'precio': 1.50,
        'quantity': 2,
        'imagen': 'https://example.com/p.jpg',
      };

      final item = CartItem.fromJson(json);

      expect(item.id, 1);
      expect(item.nombre, 'Paracetamol 500mg');
      expect(item.precio, 1.50);
      expect(item.quantity, 2);
      expect(item.imagen, 'https://example.com/p.jpg');
    });

    test('Parsea flags Pharma desde JSON', () {
      final json = {
        'id': 5,
        'nombre': 'Amoxicilina 500mg',
        'precio': 3.20,
        'quantity': 1,
        'requires_prescription': true,
        'prescription_type': 'common',
        'controlled_substance': false,
        'cold_chain': false,
        'active_ingredient': 'amoxicilina',
        'concentration': '500mg',
        'presentation': 'Caja x 21',
      };
      final item = CartItem.fromJson(json);

      expect(item.requiresPrescription, true);
      expect(item.prescriptionType, 'common');
      expect(item.controlledSubstance, false);
      expect(item.coldChain, false);
      expect(item.activeIngredient, 'amoxicilina');
      expect(item.concentration, '500mg');
      expect(item.presentation, 'Caja x 21');
    });

    test('Maneja precio como entero en JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Paracetamol 500mg',
        'precio': 15,
        'quantity': 2,
      };
      final item = CartItem.fromJson(json);
      expect(item.precio, 15.0);
    });

    test('Maneja precio como string en JSON', () {
      final json = {
        'id': 1,
        'nombre': 'Vitamina C',
        'precio': '15.50',
        'quantity': 2,
      };
      final item = CartItem.fromJson(json);
      expect(item.precio, 15.50);
    });

    test('Compara items iguales', () {
      final item1 = CartItem(
          id: 1, nombre: 'A', precio: 1.0, quantity: 1, imagen: '');
      final item2 = CartItem(
          id: 1, nombre: 'A', precio: 1.0, quantity: 1, imagen: '');
      expect(item1, equals(item2));
    });

    test('Compara items diferentes', () {
      final item1 = CartItem(
          id: 1, nombre: 'A', precio: 1.0, quantity: 1, imagen: '');
      final item2 = CartItem(
          id: 2, nombre: 'B', precio: 2.0, quantity: 1, imagen: '');
      expect(item1, isNot(equals(item2)));
    });
  });
}
