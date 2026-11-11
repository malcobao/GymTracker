/// Enumerations shared by the models. Each value knows the exact string the
/// database stores (see the CHECK constraints in supabase/migrations).
library;

enum Sex {
  male('male', 'Male'),
  female('female', 'Female'),
  unspecified('unspecified', 'Prefer not to say');

  const Sex(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static Sex fromDb(String value) =>
      values.firstWhere((v) => v.dbValue == value);
}

enum ExperienceLevel {
  beginner('beginner', 'Beginner'),
  intermediate('intermediate', 'Intermediate'),
  advanced('advanced', 'Advanced');

  const ExperienceLevel(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static ExperienceLevel fromDb(String value) =>
      values.firstWhere((v) => v.dbValue == value);
}

enum Goal {
  strength('strength', 'Get stronger'),
  muscleGain('muscle_gain', 'Build muscle'),
  fatLoss('fat_loss', 'Lose fat'),
  generalFitness('general_fitness', 'General fitness');

  const Goal(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static Goal fromDb(String value) =>
      values.firstWhere((v) => v.dbValue == value);
}

enum WeightUnit {
  kg('kg'),
  lb('lb');

  const WeightUnit(this.dbValue);
  final String dbValue;

  static WeightUnit fromDb(String value) =>
      values.firstWhere((v) => v.dbValue == value);
}

enum MuscleGroup {
  chest('chest', 'Chest'),
  back('back', 'Back'),
  shoulders('shoulders', 'Shoulders'),
  biceps('biceps', 'Biceps'),
  triceps('triceps', 'Triceps'),
  legs('legs', 'Legs'),
  glutes('glutes', 'Glutes'),
  core('core', 'Core'),
  fullBody('full_body', 'Full body'),
  other('other', 'Other');

  const MuscleGroup(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static MuscleGroup? fromDb(String? value) =>
      value == null ? null : values.firstWhere((v) => v.dbValue == value);
}
