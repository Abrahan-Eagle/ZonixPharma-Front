import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zonix/features/screens/cart/checkout_page.dart';
import 'package:zonix/features/services/cart_service.dart';
import 'package:zonix/features/services/order_service.dart';
import 'package:zonix/features/services/pharma_policy_service.dart';
import 'package:zonix/features/services/prescription_service.dart';
import 'package:zonix/models/cart_item.dart';
import 'package:zonix/models/prescription.dart';

class _FakePrescriptionService extends PrescriptionService {
  _FakePrescriptionService(this._seed);

  final List<Prescription> _seed;

  @override
  Future<void> loadMyPrescriptions() async {
    seedMyPrescriptionsForTesting(_seed);
  }
}

Prescription _approvedRx({required int id, required int commerceId}) {
  final now = DateTime(2026, 6, 11);
  return Prescription(
    id: id,
    patientProfileId: 1,
    orderId: null,
    commerceId: commerceId,
    prescribingDoctorName: 'Dr. Smoke Demo',
    imageUrl: 'prescriptions/demo.jpg',
    prescriptionType: Prescription.typeCommon,
    status: Prescription.statusApproved,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  tearDown(PharmaPolicyService.resetCacheForTesting);

  testWidgets('Checkout modo estricto muestra picker de receta aprobada',
      (WidgetTester tester) async {
    PharmaPolicyService.seedCacheForTesting(blockRx: true);

    final cart = CartService();
    cart.addToCart(
      CartItem(
        id: 3,
        nombre: 'Amoxicilina 500 mg',
        precio: 20.16,
        quantity: 1,
        commerceId: 1,
        requiresPrescription: true,
      ),
    );

    final rxService = _FakePrescriptionService([_approvedRx(id: 1, commerceId: 1)]);

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<CartService>.value(value: cart),
            ChangeNotifierProvider<PrescriptionService>.value(value: rxService),
            ChangeNotifierProvider<OrderService>(
              create: (_) => OrderService(),
            ),
          ],
          child: const CheckoutPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modo estricto Rx'), findsOneWidget);
    expect(find.text('Receta aprobada'), findsOneWidget);
    expect(find.textContaining('#1'), findsOneWidget);
  });
}
