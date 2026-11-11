/// Enumerations shared by the models. Each value knows the exact text stored
/// in the database (see the CHECK constraints in `app_database.dart`).
/// Display labels are translated in the UI (`ui/core/labels.dart`).
library;

enum Sex {
  male('male'),
  female('female'),
  unspecified('unspecified');

  const Sex(this.dbValue);
  final String dbValue;

  static Sex fromDb(String value) =>
      values.firstWhere((v) => v.dbValue == value);
}

enum ExperienceLevel {
  beginner('beginner'),
  intermediate('intermediate'),
  advanced('advanced');

  const ExperienceLevel(this.dbValue);
  final String dbValue;

  static ExperienceLevel fromDb(String value) =>
      values.firstWhere((v) => v.dbValue == value);
}

enum Goal {
  strength('strength'),
  muscleGain('muscle_gain'),
  fatLoss('fat_loss'),
  generalFitness('general_fitness');

  const Goal(this.dbValue);
  final String dbValue;

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
  chest('chest'),
  back('back'),
  shoulders('shoulders'),
  biceps('biceps'),
  triceps('triceps'),
  legs('legs'),
  glutes('glutes'),
  core('core'),
  fullBody('full_body'),
  other('other');

  const MuscleGroup(this.dbValue);
  final String dbValue;

  static MuscleGroup? fromDb(String? value) =>
      value == null ? null : values.firstWhere((v) => v.dbValue == value);
}
