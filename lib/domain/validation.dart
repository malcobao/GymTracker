/// Why a form field is invalid. The UI turns it into a translated message
/// (`ui/core/labels.dart`), so this file has no Flutter or language code.
enum FieldErrorCode {
  required,
  tooLong,
  notANumber,
  notAWholeNumber,
  outOfRange,
  duplicate,
}

class FieldError {
  const FieldError(this.code, {this.min, this.max});

  final FieldErrorCode code;
  final num? min;
  final num? max;

  @override
  bool operator ==(Object other) =>
      other is FieldError &&
      other.code == code &&
      other.min == min &&
      other.max == max;

  @override
  int get hashCode => Object.hash(code, min, max);

  @override
  String toString() => 'FieldError($code, $min, $max)';
}

/// Form validation that mirrors the database CHECK and UNIQUE constraints.
/// The forms run it on every keystroke (real-time validation); the database
/// stays the final authority. Each function returns null when valid.
abstract final class Validation {
  static const minHeightCm = 50.0;
  static const maxHeightCm = 272.0;
  static const minBodyWeightKg = 20.0;
  static const maxBodyWeightKg = 400.0;
  static const maxLiftKg = 1000.0;
  static const maxReps = 200;
  static const maxTargetSets = 20;
  static const maxTargetReps = 100;
  static const maxNameLength = 60;
  static const maxDisplayNameLength = 50;
  static const maxDescriptionLength = 500;
  static const minAge = 10;
  static const maxAge = 100;

  /// A required name of at most [max] characters that is not in [taken]
  /// (compared without case, like the database's `COLLATE NOCASE` index).
  static FieldError? name(
    String? value, {
    int max = maxNameLength,
    Iterable<String> taken = const [],
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return const FieldError(FieldErrorCode.required);
    if (v.length > max) return FieldError(FieldErrorCode.tooLong, max: max);
    final lower = v.toLowerCase();
    if (taken.any((t) => t.trim().toLowerCase() == lower)) {
      return const FieldError(FieldErrorCode.duplicate);
    }
    return null;
  }

  static FieldError? optionalText(String? value, {required int max}) =>
      (value?.trim().length ?? 0) > max
      ? FieldError(FieldErrorCode.tooLong, max: max)
      : null;

  /// Parses a decimal typed by the user; accepts a comma as decimal separator.
  static double? parseDecimal(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  /// A required decimal between [min] and [max] (inclusive).
  static FieldError? decimal(
    String? value, {
    required double min,
    required double max,
  }) {
    if ((value ?? '').trim().isEmpty) {
      return const FieldError(FieldErrorCode.required);
    }
    final number = parseDecimal(value);
    if (number == null) return const FieldError(FieldErrorCode.notANumber);
    if (number < min || number > max) {
      return FieldError(FieldErrorCode.outOfRange, min: min, max: max);
    }
    return null;
  }

  /// A required whole number between [min] and [max] (inclusive).
  static FieldError? wholeNumber(
    String? value, {
    int min = 1,
    required int max,
  }) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return const FieldError(FieldErrorCode.required);
    final number = int.tryParse(v);
    if (number == null) return const FieldError(FieldErrorCode.notAWholeNumber);
    if (number < min || number > max) {
      return FieldError(FieldErrorCode.outOfRange, min: min, max: max);
    }
    return null;
  }

  static FieldError? reps(String? value) => wholeNumber(value, max: maxReps);

  /// Like [wholeNumber] but empty is allowed.
  static FieldError? optionalCount(String? value, {required int max}) =>
      (value ?? '').trim().isEmpty ? null : wholeNumber(value, max: max);

  /// Birth date giving an age between [minAge] and [maxAge] on [today].
  static FieldError? birthDate(DateTime? value, DateTime today) {
    if (value == null) return const FieldError(FieldErrorCode.required);
    var age = today.year - value.year;
    if (today.month < value.month ||
        (today.month == value.month && today.day < value.day)) {
      age--;
    }
    if (age < minAge || age > maxAge) {
      return const FieldError(
        FieldErrorCode.outOfRange,
        min: minAge,
        max: maxAge,
      );
    }
    return null;
  }

  static FieldError? requiredChoice(Object? value) =>
      value == null ? const FieldError(FieldErrorCode.required) : null;
}
