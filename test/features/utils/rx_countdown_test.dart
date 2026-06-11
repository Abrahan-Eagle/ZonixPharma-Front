import 'package:flutter_test/flutter_test.dart';
import 'package:zonix/features/utils/rx_countdown.dart';

void main() {
  group('formatRxCountdownLabel', () {
    final now = DateTime(2026, 6, 10, 12, 0);

    test('plazo vencido', () {
      expect(
        formatRxCountdownLabel(now.subtract(const Duration(minutes: 1)), now),
        'Plazo vencido',
      );
    });

    test('menos de 1 minuto', () {
      expect(
        formatRxCountdownLabel(now.add(const Duration(seconds: 30)), now),
        'Queda menos de 1 min',
      );
    });

    test('minutos', () {
      expect(
        formatRxCountdownLabel(now.add(const Duration(minutes: 45)), now),
        'Quedan 45 min',
      );
    });

    test('horas y minutos', () {
      expect(
        formatRxCountdownLabel(now.add(const Duration(hours: 2, minutes: 15)), now),
        'Quedan 2h 15min',
      );
    });
  });
}
