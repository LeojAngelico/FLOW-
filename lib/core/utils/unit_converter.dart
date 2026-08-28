/// Canonical storage is always metric (integer ml, double kg) per
/// BR-40/BR-41 — imperial is presentation-only. These conversions are
/// the single source of truth for that presentation layer.
class UnitConverter {
  UnitConverter._();

  static const double _mlPerFlOz = 29.5735;
  static const double _kgPerLb = 0.453592;

  static double mlToFlOz(int ml) => ml / _mlPerFlOz;

  static int flOzToMl(double flOz) => (flOz * _mlPerFlOz).round();

  static double kgToLb(double kg) => kg / _kgPerLb;

  static double lbToKg(double lb) => lb * _kgPerLb;
}
