/// The only place a hydration volume becomes a display string. Metric
/// only for now — see `docs/workplans/2026-09-04-hydration-logging.md`
/// § Explicitly out of scope: "all formatting goes through one formatter
/// so imperial is a one-file change later."
library;

/// `750 -> '750 ml'`, `1250 -> '1.25 L'`, `2400 -> '2.4 L'`,
/// `1000 -> '1 L'`. Switches to litres at 1,000 ml, showing up to two
/// decimal places with trailing zeros (and a trailing `.`) trimmed, so a
/// whole number of litres reads as `'2 L'`, not `'2.00 L'`.
String formatVolumeMl(int amountMl) {
  if (amountMl < 1000) {
    return '$amountMl ml';
  }

  final liters = amountMl / 1000;
  var text = liters.toStringAsFixed(2);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  return '$text L';
}

/// `0.63 -> '63%'`. [fraction] is a `0.0`-`1.0` ratio (or occasionally
/// above `1.0`, e.g. `progressFraction` past target) rounded to the
/// nearest whole percent — never floored/ceiled, so `0.625` reads as
/// `'63%'`, matching how a person would round it aloud.
String formatPercent(double fraction) {
  return '${(fraction * 100).round()}%';
}
