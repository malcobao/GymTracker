import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/models/user_profile.dart';
import 'package:gym_tracker/domain/progress_calculator.dart';
import 'package:gym_tracker/domain/validation.dart';
import 'package:gym_tracker/utils/units.dart';

import '../helpers.dart';

void main() {
  group('Validation (mirrors the database rules)', () {
    test('names: required, max length, unique ignoring case', () {
      expect(Validation.name(''), const FieldError(FieldErrorCode.required));
      expect(
        Validation.name('x' * 61),
        const FieldError(FieldErrorCode.tooLong, max: 60),
      );
      expect(
        Validation.name(' push ', taken: ['Push']),
        const FieldError(FieldErrorCode.duplicate),
      );
      expect(Validation.name('Pull', taken: ['Push']), isNull);
    });

    test('decimals accept a comma and check the range', () {
      expect(Validation.parseDecimal('62,5'), 62.5);
      expect(
        Validation.decimal('abc', min: 0, max: 10)?.code,
        FieldErrorCode.notANumber,
      );
      expect(
        Validation.decimal('11', min: 0, max: 10)?.code,
        FieldErrorCode.outOfRange,
      );
      expect(Validation.decimal('10', min: 0, max: 10), isNull);
    });

    test('reps are whole numbers 1–200', () {
      expect(Validation.reps('2.5')?.code, FieldErrorCode.notAWholeNumber);
      expect(Validation.reps('0')?.code, FieldErrorCode.outOfRange);
      expect(Validation.reps('201')?.code, FieldErrorCode.outOfRange);
      expect(Validation.reps('12'), isNull);
    });

    test('optional counts may be empty', () {
      expect(Validation.optionalCount('', max: 20), isNull);
      expect(
        Validation.optionalCount('21', max: 20)?.code,
        FieldErrorCode.outOfRange,
      );
    });

    test('birth date gives an age between 10 and 100', () {
      final today = DateTime(2026, 11, 10);
      expect(Validation.birthDate(null, today)?.code, FieldErrorCode.required);
      expect(
        Validation.birthDate(DateTime(2020), today)?.code,
        FieldErrorCode.outOfRange,
      );
      expect(Validation.birthDate(DateTime(2003, 4, 15), today), isNull);
    });
  });

  group('ProgressCalculator', () {
    test('Epley estimate; one rep is the weight itself', () {
      expect(ProgressCalculator.estimatedOneRepMax(100, 1), 100);
      expect(ProgressCalculator.estimatedOneRepMax(60, 8), 76);
    });

    test('groups sets by day, oldest first', () {
      final days = ProgressCalculator.byDay([
        record(date: DateTime(2026, 11, 9), weightKg: 70, reps: 8),
        record(date: DateTime(2026, 11, 2), weightKg: 60, reps: 8),
        record(date: DateTime(2026, 11, 2), weightKg: 62.5, reps: 6),
      ]);
      expect(days.map((d) => d.date), [
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 9),
      ]);
      expect(days.first.topWeightKg, 62.5);
      expect(days.first.volumeKg, 855);
      expect(days.first.setCount, 2);
      expect(days.last.estimatedOneRepMaxKg, closeTo(88.67, 0.01));
    });
  });

  group('profile', () {
    test('age and BMI are calculated, not stored', () {
      final p = sampleProfile();
      expect(p.ageOn(DateTime(2026, 4, 14)), 22);
      expect(p.ageOn(DateTime(2026, 4, 15)), 23);
      expect(p.bmi, closeTo(23.83, 0.01));
      expect(p.toRow().containsKey('bmi'), isFalse);
    });

    test('dates are stored as sortable text', () {
      expect(dateOnly(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
    });
  });

  test('Units: kg unchanged, exact pound definition', () {
    expect(Units.fromKg(80, WeightUnit.kg), 80);
    expect(Units.toKg(100, WeightUnit.lb), closeTo(45.359237, 1e-9));
    expect(
      Units.fromKg(Units.toKg(225, WeightUnit.lb), WeightUnit.lb),
      closeTo(225, 1e-9),
    );
  });
}
