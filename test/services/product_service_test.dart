import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zonix/features/services/product_service.dart';
import 'package:zonix/models/product.dart';

class ProductServiceMock extends ProductService {
  @override
  Future<List<Product>> fetchProducts({int? categoryId}) async {
    // Mock de respuesta exitosa
    final mockClient = MockClient((request) async {
      const payload = '[{'
          '"id":1,"commerce_id":9,"name":"Ibuprofeno 400mg","description":"OTC",'
          '"is_available":true,"price":10.0,"image":"img.jpg","category_name":"Analgesicos",'
          '"stock":50,"tags":[],"rating":4.5,"review_count":2,'
          '"created_at":"2024-01-01T00:00:00.000Z","updated_at":"2024-01-01T00:00:00.000Z",'
          '"active_ingredient":"Ibuprofeno","dosage_form":"Comprimido","concentration":"400 mg",'
          '"presentation":"Caja x 20","requires_prescription":false,"prescription_type":"common",'
          '"controlled_substance":false,"cold_chain":false,'
          '"health_registry":"DEMO-INHRR-001","atc_code":"M01AE01"'
          '}]';
      return http.Response(payload, 200);
    });
    final headers = {'Content-Type': 'application/json'};
    final response = await mockClient.get(
      Uri.parse(apiUrl),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Error al cargar productos');
    }
  }
}

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: ".env");
  });
  group('ProductService', () {
    test('fetchProducts returns a list', () async {
      final service = ProductServiceMock();
      try {
        final products = await service.fetchProducts();
        expect(products, isA<List>());
        if (products.isNotEmpty) {
          expect(products.first, isNotNull);
          expect(products.first.name, isNotEmpty);
          expect(products.first.commerceId, 9);
          expect(products.first.activeIngredient, 'Ibuprofeno');
          expect(products.first.requiresPrescription, false);
          expect(products.first.coldChain, false);
        }
      } catch (e) {
        fail('Error al obtener productos: $e');
      }
    });
  });
}
