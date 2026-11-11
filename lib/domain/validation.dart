/// Form validation that mirrors the database CHECK constraints in
/// supabase/migrations. The database stays the final authority; these give the
/// user instant feedback. Each function returns an error message or null.
abstract final class Validation {
  static const minHeightCm = 50.0;
  static const maxHeightCm = 272.0;
  static const minBodyWeightKg = 20.0;
  static const maxBodyWeightKg = 400.0;
  static const maxLiftKg = 1000.0;
  static const maxReps = 200;
  static const maxNameLength = 60;
  static const maxDisplayNameLength = 50;
  static const minPasswordLength = 8;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    return null;
  }

  static String? requiredName(String? value, {int max = maxNameLength}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter a name';
    if (v.length > max) return 'Use at most $max characters';
    return null;
  }

  /// Parses a decimal typed by the user; accepts a comma as decimal separator.
  static double? parseDecimal(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  static String? range(
    String? value, {
    required double min,
    required double max,
    required String unit,
  }) {
    final number = parseDecimal(value);
    if (number == null) return 'Enter a number';
    if (number < min || number > max) {
      return 'Must be between ${_fmt(min)} and ${_fmt(max)} $unit';
    }
    return null;
  }

  static String? reps(String? value) {
    final number = int.tryParse((value ?? '').trim());
    if (number == null) return 'Enter whole reps';
    if (number < 1 || number > maxReps) return 'Reps must be 1 to $maxReps';
    return null;
  }

  static String? optionalCount(String? value, {required int max}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return null;
    final number = int.tryParse(v);
    if (number == null || number < 1 || number > max) return '1 to $max';
    return null;
  }

  static String _fmt(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toString();
}
