import 'enums.dart';

/// The onboarding profile stored in the `users` table. Login data (email,
/// password) lives in Supabase Auth, not here.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.birthDate,
    required this.sex,
    required this.heightCm,
    required this.bodyWeightKg,
    required this.experienceLevel,
    required this.goal,
    this.weightUnit = WeightUnit.kg,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    displayName: json['display_name'] as String,
    birthDate: DateTime.parse(json['birth_date'] as String),
    sex: Sex.fromDb(json['sex'] as String),
    heightCm: (json['height_cm'] as num).toDouble(),
    bodyWeightKg: (json['body_weight_kg'] as num).toDouble(),
    experienceLevel: ExperienceLevel.fromDb(json['experience_level'] as String),
    goal: Goal.fromDb(json['goal'] as String),
    weightUnit: WeightUnit.fromDb(json['weight_unit'] as String),
  );

  final String id;
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': displayName,
    'birth_date': dateOnly(birthDate),
    'sex': sex.dbValue,
    'height_cm': heightCm,
    'body_weight_kg': bodyWeightKg,
    'experience_level': experienceLevel.dbValue,
    'goal': goal.dbValue,
    'weight_unit': weightUnit.dbValue,
  };
}

/// Formats a date as `YYYY-MM-DD`, the format PostgreSQL `DATE` columns use.
String dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
