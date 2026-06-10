import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/utils/order_tracking_controller.dart';

void main() {
  group('OrderTrackingController', () {
    test('stepMap incluye pending_prescription_validation', () {
      expect(
        OrderTrackingController.progressStep('pending_prescription_validation'),
        0,
      );
      expect(
        OrderTrackingController.progressFraction(
            'pending_prescription_validation'),
        0.10,
      );
    });

    test('isCancellable permite Rx y pending_payment', () {
      expect(
        OrderTrackingController.isCancellable('pending_prescription_validation'),
        isTrue,
      );
      expect(OrderTrackingController.isCancellable('pending_payment'), isTrue);
      expect(OrderTrackingController.isCancellable('processing'), isFalse);
    });

    test('isTrackable incluye estados pre-checkout', () {
      expect(
        OrderTrackingController.isTrackable('pending_prescription_validation'),
        isTrue,
      );
      expect(OrderTrackingController.isTrackable('delivered'), isFalse);
    });
  });
}
