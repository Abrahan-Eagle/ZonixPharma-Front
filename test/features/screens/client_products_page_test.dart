import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/screens/products/products_page.dart';
import 'package:zonix/models/product.dart';
import 'package:zonix/features/services/cart_service.dart';
import 'package:zonix/features/services/product_service.dart';
import 'package:zonix/features/services/location_service.dart';
import 'package:zonix/features/utils/search_radius_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLocationService extends LocationService {
  @override
  Future<Map<String, dynamic>> getCurrentLocation() async => {
        'latitude': -12.0,
        'longitude': -77.0,
        'address': 'Test',
      };
  @override
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radius = 5.0,
    String? type,
  }) async =>
      [
        {'id': 1, 'name': 'Test Pharmacy', 'distance': 1.0},
      ];
}

class MockProductService implements ProductService {
  @override
  final String apiUrl = 'http://test.com/api/products';

  Product _otc(int id, String name) => Product(
        id: id,
        commerceId: 1,
        name: name,
        description: 'Producto OTC de prueba',
        price: 1.50,
        image: '',
        category: 'Analgésicos y antipiréticos',
        isAvailable: true,
        stock: 10,
        tags: const [],
        rating: 4.5,
        reviewCount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        activeIngredient: 'paracetamol',
        dosageForm: 'tablet',
        concentration: '500mg',
        presentation: 'Caja x 20 tabletas',
        manufacturer: 'Lab Demo',
        healthRegistry: 'E.F. 12345',
        requiresPrescription: false,
        controlledSubstance: false,
        coldChain: false,
      );

  Product _rx(int id, String name) => Product(
        id: id,
        commerceId: 1,
        name: name,
        description: 'Antibiótico Rx demo',
        price: 8.20,
        image: '',
        category: 'Antibióticos',
        isAvailable: true,
        stock: 5,
        tags: const [],
        rating: 4.3,
        reviewCount: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        activeIngredient: 'amoxicilina',
        dosageForm: 'capsule',
        concentration: '500mg',
        presentation: 'Caja x 21 cápsulas',
        manufacturer: 'Lab Demo',
        healthRegistry: 'E.F. 67890',
        requiresPrescription: true,
        prescriptionType: 'common',
        controlledSubstance: false,
        coldChain: false,
      );

  @override
  Future<List<Product>> fetchProducts({int? categoryId}) async {
    return [_otc(1, 'Paracetamol 500mg'), _rx(2, 'Amoxicilina 500mg')];
  }

  @override
  Future<BuyerProductsPageResult> fetchProductsPage({
    required int page,
    int perPage = 20,
    int? categoryId,
  }) async {
    final items = await fetchProducts(categoryId: categoryId);
    return BuyerProductsPageResult(
      products: items,
      currentPage: 1,
      lastPage: 1,
      total: items.length,
    );
  }

  @override
  Future<List<Product>> fetchProductsByCommerce(int commerceId) async {
    return fetchProducts();
  }

  @override
  Future<BuyerProductsPageResult> fetchProductsByCommercePage({
    required int commerceId,
    required int page,
    int perPage = 20,
    String? search,
  }) async {
    final items = await fetchProducts();
    return BuyerProductsPageResult(
      products: items,
      currentPage: 1,
      lastPage: 1,
      total: items.length,
    );
  }

  @override
  Future<BuyerProductsPageResult> fetchSearchProductsPage({
    required int page,
    int perPage = 20,
    String? search,
    int? commerceId,
    int? categoryId,
    bool? available,
  }) async {
    final items = await fetchProducts(categoryId: categoryId);
    return BuyerProductsPageResult(
      products: items,
      currentPage: 1,
      lastPage: 1,
      total: items.length,
    );
  }

  Future<Product?> fetchProduct(int id) async => _otc(id, 'Producto $id');

  Future<List<Product>> searchProducts(String query) async => [];

  @override
  Future<Product> getProductById(int productId) async =>
      _otc(productId, 'Producto $productId');
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: ".env");
  });

  testWidgets('Buyer ve productos farmacéuticos sin acciones de comercio/delivery',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartService>(create: (_) => CartService()),
          ChangeNotifierProvider<LocationService>(
              create: (_) => MockLocationService()),
          ChangeNotifierProvider<SearchRadiusProvider>(
              create: (_) => SearchRadiusProvider()),
        ],
        child: MaterialApp(
          home: ProductsPage(productService: MockProductService()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Paracetamol 500mg'), findsAtLeastNWidgets(1));
    expect(find.text('Amoxicilina 500mg'), findsAtLeastNWidgets(1));
    expect(find.text('Agregar producto'), findsNothing);
    expect(find.text('Órdenes asignadas'), findsNothing);
  });
}
