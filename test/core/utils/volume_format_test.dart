import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/utils/volume_format.dart';

void main() {
  group('formatVolumeMl', () {
    test('0ml', () {
      expect(formatVolumeMl(0), '0 ml');
    });

    test('999ml -- just under the litre switchover', () {
      expect(formatVolumeMl(999), '999 ml');
    });

    test('1000ml -- switches to litres and trims a whole-number decimal', () {
      expect(formatVolumeMl(1000), '1 L');
    });

    test('1250ml -- two decimal places, no trailing zero to trim', () {
      expect(formatVolumeMl(1250), '1.25 L');
    });

    test('2400ml -- one trailing zero trimmed', () {
      expect(formatVolumeMl(2400), '2.4 L');
    });
  });

  group('formatPercent', () {
    test('0.0 -> 0%', () {
      expect(formatPercent(0.0), '0%');
    });

    test('rounds to the nearest whole percent, not floor/ceil', () {
      expect(formatPercent(0.625), '63%');
    });

    test('1.0 -> 100%', () {
      expect(formatPercent(1.0), '100%');
    });

    test('exceeds 100% uncapped, past the goal (FR-033 textual readout)', () {
      expect(formatPercent(1.5), '150%');
    });
  });
}
