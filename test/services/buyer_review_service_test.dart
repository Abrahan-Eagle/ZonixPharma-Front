import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/services/buyer_review_service.dart';

void main() {
  group('BuyerReviewService', () {
    late BuyerReviewService reviewService;

    setUp(() {
      reviewService = BuyerReviewService();
    });

    test('ratePharmacy es alias de rateRestaurant', () {
      expect(reviewService.ratePharmacy, isA<Function>());
      expect(reviewService.rateRestaurant, isA<Function>());
    });
  });
}
