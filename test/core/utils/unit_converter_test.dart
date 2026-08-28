import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/utils/unit_converter.dart';

void main() {
  test('mlToFlOz converts using 1 fl oz = 29.5735 ml', () {
    expect(UnitConverter.mlToFlOz(295735), closeTo(10000, 0.01));
  });

  test('flOzToMl rounds to the nearest whole millilitre', () {
    expect(UnitConverter.flOzToMl(1), 30);
  });

  test('kgToLb converts using 1 lb = 0.453592 kg', () {
    expect(UnitConverter.kgToLb(1), closeTo(2.2046, 0.001));
  });

  test('lbToKg converts using 1 lb = 0.453592 kg', () {
    expect(UnitConverter.lbToKg(1), closeTo(0.453592, 0.000001));
  });

  test('kgToLb and lbToKg round-trip within a small tolerance', () {
    const originalKg = 68.0;
    final roundTripped = UnitConverter.lbToKg(UnitConverter.kgToLb(originalKg));

    expect(roundTripped, closeTo(originalKg, 0.001));
  });
}
