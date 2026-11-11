import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/domain/models/enums.dart';
import 'package:gym_tracker/domain/validation.dart';
import 'package:gym_tracker/utils/units.dart';

void main() {
  group('Validation (mirrors the database CHECK constraints)', () {
    test('email', () {
      expect(Validation.email('ana@example.com'), isNull);
      expect(Validation.email(''), isNotNull);
      expect(Validation.email('ana@'), isNotNull);
    });

    test('password length', () {
      expect(Validation.password('1234567'), isNotNull);
      expect(Validation.password('12345678'), isNull);
    });

    test('reps 1..200', () {
      expect(Validation.reps('0'), isNotNull);
      expect(Validation.reps('1'), isNull);
      expect(Validation.reps('200'), isNull);
      expect(Validation.reps('201'), isNotNull);
      expect(Validation.reps('8.5'), isNotNull);
    });

    test('range accepts a comma decimal separator', () {
      expect(Validation.range('62,5', min: 0, max: 1000, unit: 'kg'), isNull);
      expect(
        Validation.range('1001', min: 0, max: 1000, unit: 'kg'),
        'Must be between 0 and 1000 kg',
      );
    });

    test('names are 1..60 characters', () {
      expect(Validation.requiredName('  '), isNotNull);
      expect(Validation.requiredName('a' * 60), isNull);
      expect(Validation.requiredName('a' * 61), isNotNull);
    });

    test('optional counts', () {
      expect(Validation.optionalCount('', max: 20), isNull);
      expect(Validation.optionalCount('21', max: 20), isNotNull);
    });
  });

  group('Units', () {
    test('kg is unchanged', () {
      expect(Units.toKg(62.5, WeightUnit.kg), 62.5);
      expect(Units.format(62.5, WeightUnit.kg), '62.5 kg');
      expect(Units.format(60, WeightUnit.kg), '60 kg');
    });

    test('pounds convert with the exact definition', () {
      expect(Units.toKg(100, WeightUnit.lb), closeTo(45.359237, 1e-9));
      expect(Units.fromKg(45.359237, WeightUnit.lb), closeTo(100, 1e-9));
      expect(Units.format(100, WeightUnit.lb), '220.5 lb');
    });
  });
}
