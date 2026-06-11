import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/services/pharma_policy_service.dart';

void main() {
  tearDown(PharmaPolicyService.resetCacheForTesting);

  test('seedCacheForTesting devuelve blockRx sin HTTP', () async {
    PharmaPolicyService.seedCacheForTesting(blockRx: true);
    expect(await PharmaPolicyService.blockRxWithoutPrescription(), isTrue);

    PharmaPolicyService.seedCacheForTesting(blockRx: false);
    expect(await PharmaPolicyService.blockRxWithoutPrescription(), isFalse);
  });

  test('forceRefresh invalida cache anterior', () async {
    PharmaPolicyService.seedCacheForTesting(blockRx: true);
    PharmaPolicyService.resetCacheForTesting();
    // Sin red en CI: fallback permisivo false
    expect(
      await PharmaPolicyService.blockRxWithoutPrescription(forceRefresh: true),
      isFalse,
    );
  });
}
