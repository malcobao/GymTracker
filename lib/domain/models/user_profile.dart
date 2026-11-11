import 'enums.dart';

/// The owner of the app (personal use: exactly one row, id = 1, in the
/// `profile` table).
class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.birthDate,
    required this.sex,
    required this.heightCm,
    required this.bodyWeightKg,
    required this.experienceLevel,
    required this.goal,
    this.weightUnit = WeightUnit.kg,
  });

  /// The only profile row always has this id.
  static const singletonId = 1;

  factory UserProfile.fromRow(Map<String, Object?> row) => UserProfile(
    displayName: row['display_name']! as String,
    birthDate: DateTime.parse(row['birth_date']! as String),
    sex: Sex.fromDb(row['sex']! as String),
    heightCm: (row['height_cm']! as num).toDouble(),
    bodyWeightKg: (row['body_weight_kg']! as num).toDouble(),
    experienceLevel: ExperienceLevel.fromDb(row['experience_level']! as String),
    goal: Goal.fromDb(row['goal']! as String),
    weightUnit: WeightUnit.fromDb(row['weight_unit']! as String),
  );

  final String displayName;
  final DateTime birthDate;
  final Sex sex;
  final double heightCm;
  final double bodyWeightKg;
  final ExperienceLevel experienceLevel;
  final Goal goal;
  final WeightUnit weightUnit;

  /// Age in whole years on [today]. Calculated, never stored.
  int ageOn(DateTime today) {
    var age = today.year - birthDate.year;
    final hadBirthday =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    if (!hadBirthday) age--;
    return age;
  }

  /// Body mass index: weight (kg) / height (m)². Calculated, never stored.
  double get bmi => bodyWeightKg / ((heightCm / 100) * (heightCm / 100));

  Map<String, Object?> toRow() => {
    'id': singletonId,
    'display_name': displayName.trim(),
    'birth_date': dateOnly(birthDate),
    'sex': sex.dbValue,
    'height_cm': heightCm,
    'body_weight_kg': bodyWeightKg,
    'experience_level': experienceLevel.dbValue,
    'goal': goal.dbValue,
    'weight_unit': weightUnit.dbValue,
  };

  UserProfile copyWith({WeightUnit? weightUnit}) => UserProfile(
    displayName: displayName,
    birthDate: birthDate,
    sex: sex,
    heightCm: heightCm,
    bodyWeightKg: bodyWeightKg,
    experienceLevel: experienceLevel,
    goal: goal,
    weightUnit: weightUnit ?? this.weightUnit,
  );
}

/// Formats a date as `YYYY-MM-DD`, the text format the database stores.
/// It sorts correctly as text, so SQL `BETWEEN` and `ORDER BY` work on it.
String dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// [date] without its time of day.
DateTime dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
