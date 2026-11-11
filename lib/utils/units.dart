import '../domain/models/enums.dart';

/// Converts between the kilograms stored in the database and the unit the
/// user chose for display.
abstract final class Units {
  /// Exact by definition (international avoirdupois pound).
  static const kgPerLb = 0.45359237;

  static double fromKg(double kg, WeightUnit unit) =>
      unit == WeightUnit.kg ? kg : kg / kgPerLb;

  static double toKg(double value, WeightUnit unit) =>
      unit == WeightUnit.kg ? value : value * kgPerLb;

  /// "62.5 kg", "137.8 lb": at most one decimal, trailing ".0" removed.
  static String format(double kg, WeightUnit unit) {
    final value = fromKg(kg, unit);
    final text = value.toStringAsFixed(1);
    return '${text.endsWith('.0') ? text.substring(0, text.length - 2) : text} ${unit.dbValue}';
  }
}
